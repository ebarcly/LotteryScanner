//
//  LotteryTypeSelectionView.swift
//  LotteryScanner
//
//  Created by Enrique Barclay on 4/26/24.
//

import SwiftUI

struct LotteryTypeSelectionView: View {
    @Binding var selectedLotteryType: LotteryType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select your Lottery")
                .font(.headline)
            
            HStack(spacing: 16) {
                ForEach(LotteryType.allCases, id: \.self) { lotteryType in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedLotteryType = lotteryType
                        }
                        HapticFeedback.playSelection()
                    }) {
                        Image(lotteryType.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                            .padding(8)
                            .background(selectedLotteryType == lotteryType ? Color.blue.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedLotteryType == lotteryType ? Color.blue : Color.gray, lineWidth: 2)
                            )
                            .scaleEffect(selectedLotteryType == lotteryType ? 1.05 : 1.0)
                    }
                }
            }
        }
    }
}
