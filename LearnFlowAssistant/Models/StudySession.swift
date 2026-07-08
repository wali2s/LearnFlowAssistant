//
//  StudySession.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 03.07.26.
//

import Foundation
struct StudySession: Identifiable, Codable {
    let id: UUID
    let goalId: UUID
    let goalTitle: String
    let startedAt: Date
    let endedAt: Date
    let durationInSeconds: Int
    
    init(id: UUID, goalId: UUID, goalTitle: String, startedAt: Date, endedAt: Date, durationInSeconds: Int) {
        self.id = id
        self.goalId = goalId
        self.goalTitle = goalTitle
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.durationInSeconds = durationInSeconds
    }
    
    
    var durationText: String{
        let minutes = durationInSeconds / 60
        let seconds = durationInSeconds % 60
        
        if minutes > 0 {
            return "\(minutes) min \(seconds) sec"
        }else{
            return "\(seconds) sec"
        }
    }
    
    var formattedStartDate: String{
        startedAt.formatted(date: .abbreviated, time: .shortened)
    }
}
