//
//  TicketNumbersView.swift
//  LotteryScanner
//
//  Created by Enrique Barclay on 4/26/24.
//

import SwiftUI

struct TicketNumbersView: View {
    @Binding var numbers: [String]  // Bindings to the array of number strings
    @Binding var megaNumber: String // Binding to the Mega Number string
    
    var body: some View {
        HStack {
            ForEach(0..<numbers.count, id: \.self) { index in
                TextField("", text: $numbers[index])  // Editable text field for each number
                    .frame(width: 50, height: 50)
                    .multilineTextAlignment(.center)
                    .background(Circle().fill(Color.blue))
                    .foregroundColor(.white)
                    .keyboardType(.numberPad)
            }
            TextField("", text: $megaNumber)  // Editable text field for the Mega Number
                .frame(width: 50, height: 50)
                .multilineTextAlignment(.center)
                .background(Circle().fill(Color.red))
                .foregroundColor(.white)
                .keyboardType(.numberPad)
        }
    }
}
