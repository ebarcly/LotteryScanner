//
//  LotteryTypeSelectionView.swift
//  LotteryScanner
//
//  Created by Enrique Barclay on 4/26/24.
//

import SwiftUI

struct LotteryTypeSelectionView: View {
    @Binding var selectedLotteryType: String
    let lotteryTypes = ["Powerball", "Mega Millions"]
    
    var body: some View {
        Text("Select your Lottery")
            .padding(.top, 24)
            .font(.title2)
        HStack(spacing: 48) {
            ForEach(lotteryTypes, id: \.self) { lottery in
                Image(lottery)
                    .resizable()
                    .scaledToFit()
                    .frame(width: selectedLotteryType == lottery ? 110 : 100,
                           height: selectedLotteryType == lottery ? 70 : 60)
                    .border(selectedLotteryType == lottery ? Color.blue : Color.clear, width: 3)
                    .onTapGesture {
                        withAnimation {
                            selectedLotteryType = lottery
                        }
                    }
                    .padding(.top, 24)
            }
        }
    }
    
}
