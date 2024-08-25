//
//  ContentViewModel.swift
//  LotteryScanner
//
//  Created by Enrique Barclay on 8/25/24.
//

import Foundation
import Combine
import SwiftUI

/// Manages the state and business logic for the Lottery Scanner app
class ContentViewModel: ObservableObject {
    /// The currently selected lottery type
    @Published var lotteryType: LotteryType = .powerball
    /// The date of the lottery drawing
    @Published var drawDate = Date()
    /// Array of play number sets. Each play is an array of 6 strings.
    @Published var plays: [[String]] = [Array(repeating: "", count: 6)]
    @Published var alertMessage = ""
    @Published var alertTitle = "Result"
    @Published var showAlert = false
    @Published var scanResult: ScanResult = .success
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    /// Sets up reactive bindings for the view model
    private func setupBindings() {
        $plays
            .dropFirst()
            .sink { [weak self] newPlays in
                if newPlays.last?.allSatisfy({ !$0.isEmpty }) == true {
                    self?.plays.append(Array(repeating: "", count: 6))
                }
            }
            .store(in: &cancellables)
    }
    
    /// Checks the ticket numbers against the lottery results
    func checkTicket() {
        let validPlays = plays.filter { play in
            play.count == 6 && play.allSatisfy { !$0.isEmpty }
        }
        
        guard !validPlays.isEmpty else {
            showAlert(title: "Error", message: "Please enter at least one complete set of numbers.")
            return
        }
        
        for play in validPlays {
            guard let megaNumber = Int(play.last!) else { continue }
            let numbers = play.prefix(5).compactMap { Int($0) }
            
            APIManager.shared.checkTicket(
                lotteryType: lotteryType.rawValue,
                date: drawDate,
                numbers: numbers,
                megaNumber: megaNumber
            ) { [weak self] result, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    } else {
                        self?.showAlert(title: "Result", message: result)
                    }
                }
            }
        }
    }
    
    func bindingForNumbers(playIndex: Int) -> Binding<[String]> {
        return Binding(
            get: { Array(self.plays[playIndex].prefix(5)) },
            set: { newValue in
                self.plays[playIndex] = newValue + [self.plays[playIndex].last ?? ""]
            }
        )
    }
    
    func bindingForMegaNumber(playIndex: Int) -> Binding<String> {
        return Binding(
            get: { self.plays[playIndex].last ?? "" },
            set: { newValue in
                self.plays[playIndex][5] = newValue
            }
        )
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

extension ContentViewModel {
    func resetEntries() {
        plays = [Array(repeating: "", count: 6)]
        drawDate = Date()
        // Add any other reset logic here
    }
}
