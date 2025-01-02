//
//  DateSelectionView.swift
//  LotteryScanner
//
//  Created by Enrique Barclay on 8/25/24.
//

import SwiftUI

struct DateSelectionView: View {
    @Binding var selectedDate: Date
    @State private var isShowingDatePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Drawing Date")
                .font(.headline)
            
            HStack {
                Text(selectedDate, style: .date)
                Spacer()
                Button(action: { isShowingDatePicker.toggle() }) {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $isShowingDatePicker) {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .presentationDetents([.height(400)])
        }
    }
}
