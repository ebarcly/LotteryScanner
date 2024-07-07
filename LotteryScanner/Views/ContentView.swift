//
//  ContentView.swift
//  LotteryScanner
//
//  Created by Enrique Barclay on 4/20/24.
//

import SwiftUI

/// The main view for the Lottery Scanner application. It manages lottery type selection, date selection,
/// ticket scanning, and number confirmation.
struct ContentView: View {
    @State private var lotteryType = "Powerball"
    @State private var drawDate = Date()
    @State private var plays: [[String]] = []  // Array to hold multiple plays each containing lottery numbers.
    @State private var isShowingScanner = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Lottery type selection view, allowing users to choose between Powerball and Mega Millions.
                LotteryTypeSelectionView(selectedLotteryType: $lotteryType)
                
                Form {
                    Section(header: Text("Drawing Date")) {
                        DatePicker("Select Date", selection: $drawDate, displayedComponents: .date)
                    }
                    
                    Section(header: Text("Ticket Numbers")) {
                        // Displays the scanned or manually entered numbers in a horizontal layout.
                        ForEach(plays.indices, id: \.self) { index in
                            HStack {
                                ForEach(plays[index].indices, id: \.self) { numberIndex in
                                    TextField("", text: Binding(get: {
                                        plays[index][numberIndex]
                                    }, set: {
                                        plays[index][numberIndex] = $0
                                    }))
                                    .padding()
                                    .background(Circle().fill(numberIndex == plays[index].count - 1 ? Color.red : Color.blue))
                                    .foregroundColor(.white)
                                }
                            }
                        }
                        .padding()
                        
                        // Button to initiate scanning of a lottery ticket.
                        Button(action: {
                            isShowingScanner = true
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Scan Ticket")
                            }
                            .font(.title3)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(40)
                        }
                        .padding()
                    }
                }
                .navigationBarHidden(true)
                .padding(.top, 24)
                
                
                // Button to verify the scanned ticket against the API.
                VStack {
                    Button(action: {
                        checkTicket()
                    }) {
                        Text("Check Ticket")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .font(.title3)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(40)
                    }
                    .padding()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Result"), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
        }
        .sheet(isPresented: $isShowingScanner) {
            ScannerView(recognizedPlays: $plays)
        }
    }
    
    /// Verifies each play from the ticket with the lottery API.
    private func checkTicket() {
        for play in plays {
            if play.count == 6, let megaNumber = Int(play.last!) {
                let numbers = play.prefix(5).compactMap { Int($0) }
                APIManager.shared.checkTicket(
                    lotteryType: lotteryType,
                    date: drawDate,
                    numbers: numbers,
                    megaNumber: megaNumber) { result, error in
                        if let error = error {
                            alertMessage = "Error: \(error.localizedDescription)"
                        } else {
                            alertMessage = result
                        }
                        showAlert = true
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
