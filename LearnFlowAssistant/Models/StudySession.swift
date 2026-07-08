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
    let duarationInSeconds: Int
    
    init(id: UUID, goalId: UUID, goalTitle: String, startedAt: Date, endedAt: Date, duarationInSeconds: Int) {
        self.id = id
        self.goalId = goalId
        self.goalTitle = goalTitle
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.duarationInSeconds = duarationInSeconds
    }
    var durationText: String{
        let minutes = duarationInSeconds / 60
        let seconds = duarationInSeconds % 60
        
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
