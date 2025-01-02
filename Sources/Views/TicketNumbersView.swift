//
//  TicketNumbersView.swift
//  LotteryScanner
//
//  Created by Enrique Barclay on 4/26/24.
//

import SwiftUI

struct TicketNumbersView: View {
    @Binding var plays: [[String]]
    @FocusState private var focusedField: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ticket Numbers")
                .font(.headline)
            
            ForEach(plays.indices, id: \.self) { playIndex in
                HStack {
                    ForEach(0..<6) { numberIndex in
                        NumberField(
                            number: binding(for: playIndex, numberIndex: numberIndex),
                            isLastNumber: numberIndex == 5,
                            fieldIndex: playIndex * 6 + numberIndex,
                            focusedField: $focusedField
                        )
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
    
    private func binding(for playIndex: Int, numberIndex: Int) -> Binding<String> {
        return Binding(
            get: { self.plays[playIndex][numberIndex] },
            set: { self.plays[playIndex][numberIndex] = $0 }
        )
    }
}

struct NumberField: View {
    @Binding var number: String
    let isLastNumber: Bool
    let fieldIndex: Int
    @FocusState.Binding var focusedField: Int?
    
    var body: some View {
        TextField("", text: $number)
            .frame(width: 50, height: 50)
            .multilineTextAlignment(.center)
            .background(Circle().fill(isLastNumber ? Color.red : Color.blue))
            .foregroundColor(.white)
            .font(.headline)
            .keyboardType(.numberPad)
            .focused($focusedField, equals: fieldIndex)
            .onChange(of: number) { _, newValue in
                let filtered = newValue.filter { $0.isNumber }
                number = String(filtered.prefix(2))
                
                if let intValue = Int(number) {
                    let maxValue = isLastNumber ? 26 : 69 // Adjust these values based on the lottery rules
                    if intValue > maxValue {
                        number = String(maxValue)
                    }
                }
                
                if number.count == 2 {
                    focusedField = fieldIndex + 1
                }
            }
    }
}
