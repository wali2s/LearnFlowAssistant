//
//  GoalState.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 09.07.26.
//

import Foundation

struct GoalState: Identifiable {
    let id = UUID()
    let goalTitle: String
    let sessionCount: Int
    let totalSeconds: Int
    
    var totalTimeText: String {
        let hour = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hour > 0 {
            return "\(hour)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}
