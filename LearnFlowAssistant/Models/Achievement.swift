//
//  Achievement.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 21.07.26.
//

import Foundation
struct Achievement: Identifiable {
    
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let currentValue: Int
    let targetValue: Int
    let progressText: String
    
    var isUnlocked: Bool {
        currentValue >= targetValue
    }
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min( Double(currentValue) / Double(targetValue), 1.0)
    }
}
