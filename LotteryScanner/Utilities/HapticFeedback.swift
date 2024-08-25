//
//  HapticFeedback.swift
//  LotteryScanner
//
//  Created by Enrique Barclay on 8/25/24.
//

import SwiftUI

class HapticFeedback {
    static func playSelection() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    static func playSuccess() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }
    
    static func playError() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.error)
    }
}
