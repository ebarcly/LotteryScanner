//
//  ScannerView.swift
//  LotteryScanner
//
//  Created by Enrique Barclay on 4/20/24.
//

import SwiftUI
import VisionKit
import Vision

struct ScannerView: UIViewControllerRepresentable {
    @Binding var recognizedPlays: [[String]]
    @Binding var scanResult: ScanResult
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: ScannerView
        
        init(parent: ScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                parent.scanResult = .failure("No document scanned")
                parent.presentationMode.wrappedValue.dismiss()
                return
            }
            
            let image = scan.imageOfPage(at: 0)
            recognizeText(in: image)
        }
        
        private func recognizeText(in image: UIImage) {
            guard let cgImage = image.cgImage else {
                parent.scanResult = .failure("Failed to process image")
                parent.presentationMode.wrappedValue.dismiss()
                return
            }
            
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let self = self else { return }
                if let error = error {
                    self.parent.scanResult = .failure("Text recognition failed: \(error.localizedDescription)")
                    self.parent.presentationMode.wrappedValue.dismiss()
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    self.parent.scanResult = .failure("No text recognized")
                    self.parent.presentationMode.wrappedValue.dismiss()
                    return
                }
                
                let recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }
                let plays = self.extractPlays(from: recognizedText)
                
                DispatchQueue.main.async {
                    self.parent.recognizedPlays = plays
                    self.parent.scanResult = plays.isEmpty ? .failure("No valid plays found") : .success
                    self.parent.presentationMode.wrappedValue.dismiss()
                }
            }
            
            request.recognitionLevel = .accurate
            
            do {
                try requestHandler.perform([request])
            } catch {
                parent.scanResult = .failure("Failed to perform text recognition: \(error.localizedDescription)")
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
        
        private func extractPlays(from text: [String]) -> [[String]] {
            // This is a simplified example. You might need to adjust this based on the actual ticket format.
            let numberPattern = "\\b\\d{1,2}\\b"
            let regex = try? NSRegularExpression(pattern: numberPattern, options: [])
            
            var plays: [[String]] = []
            var currentPlay: [String] = []
            
            for line in text {
                guard let matches = regex?.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) else { continue }
                
                for match in matches {
                    if let range = Range(match.range, in: line) {
                        let number = String(line[range])
                        currentPlay.append(number)
                        
                        if currentPlay.count == 6 {
                            plays.append(currentPlay)
                            currentPlay = []
                        }
                    }
                }
            }
            
            return plays
        }
    }
}

enum ScanResult: Equatable {
    case success
    case failure(String)
    
    static func == (lhs: ScanResult, rhs: ScanResult) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success):
            return true
        case let (.failure(lhsError), .failure(rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

struct ScannerViewWrapper: View {
    @Binding var recognizedPlays: [[String]]
    @State private var isShowingScanner = false
    @State private var scanResult: ScanResult = .success
    @State private var showingFeedback = false
    let lotteryType: String
    
    var body: some View {
        VStack {
            Text("Scan your \(lotteryType) ticket")
                .font(.title)
                .padding()
            
            Button(action: {
                isShowingScanner = true
            }) {
                Text("Start Scanning")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if !recognizedPlays.isEmpty {
                Button(action: checkTicket) {
                    Text("Check Ticket")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            ScannerView(recognizedPlays: $recognizedPlays, scanResult: $scanResult)
        }
        .alert(isPresented: $showingFeedback) {
            switch scanResult {
            case .success:
                return Alert(title: Text("Scan Result"), message: Text("Ticket scanned successfully. You can now check if it's a winner."), dismissButton: .default(Text("OK")))
            case .failure(let error):
                return Alert(title: Text("Scan Failed"), message: Text(error), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func checkTicket() {
        // This is where you would typically call your API to check if the ticket is a winner
        // For this example, we'll simulate a response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let isWinner = Bool.random() // Simulate a random win/loss
            showingFeedback = true
            scanResult = isWinner ? .success : .failure("Sorry, this ticket is not a winner.")
        }
    }
}

struct ScannerViewWrapper_Previews: PreviewProvider {
    @State static var recognizedPlays: [[String]] = []
    
    static var previews: some View {
        ScannerViewWrapper(recognizedPlays: $recognizedPlays, lotteryType: "Mega Millions")
    }
}
