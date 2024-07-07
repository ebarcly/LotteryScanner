//
//  ScannerView.swift
//  LotteryScanner
//
//  Created by Enrique Barclay on 4/20/24.
//

import SwiftUI
import VisionKit
import Vision

/// A view that manages the camera interface to scan documents and recognize text from lottery tickets.
struct ScannerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var recognizedPlays: [[String]]  // Holds the recognized plays from the scanned ticket
    
    /// Creates the camera view controller and sets the delegate.
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    /// Required by the protocol, but not used in this implementation.
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    /// Creates a coordinator to handle the camera and text recognition.
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    /// Coordinator to manage text recognition from the camera input.
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: ScannerView
        private let playRegex = try? NSRegularExpression(pattern: "[A-Z]\\.\\s*((\\d{1,2}\\s+){5}\\d{1,2})")
        
        init(parent: ScannerView) {
            self.parent = parent
        }
        
        /// Handles the camera view closure and processes each scanned page.
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            for pageIndex in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                extractText(from: image)
            }
            controller.dismiss(animated: true)
        }
        
        /// Processes the image for text extraction using Vision framework.
        private func extractText(from image: UIImage) {
            guard let cgImage = image.cgImage else { return }
            
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("OCR error: \(error.localizedDescription)")
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    print("No OCR results")
                    return
                }
                
                self.processObservations(observations)
            }
            request.recognitionLevel = .accurate
            request.customWords = (0...69).map { String($0) } + (1...26).map { String($0) }
            request.recognitionLanguages = ["en_US"]
            request.usesLanguageCorrection = false
            
            try? requestHandler.perform([request])
        }
        
        /// Processes OCR observations to extract numbers associated with lottery plays.
        private func processObservations(_ observations: [VNRecognizedTextObservation]) {
            var plays = [[String]]()
            
            for observation in observations {
                guard let text = observation.topCandidates(1).first?.string else { continue }
                if let match = playRegex?.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
                   let range = Range(match.range(at: 1), in: text) {
                    let numbersText = String(text[range])
                    let numbers = numbersText.split(separator: " ").map { String($0) }
                    if numbers.count == 6 {
                        plays.append(numbers)
                    }
                } else {
                    print("Skipped text: \(text)")
                }
            }
            
            DispatchQueue.main.async {
                print("Recognized Plays: \(plays)")
                self.parent.recognizedPlays = plays
            }
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    @State static var recognizedPlays: [[String]] = []
    
    static var previews: some View {
        ScannerView(recognizedPlays: $recognizedPlays)
    }
}
