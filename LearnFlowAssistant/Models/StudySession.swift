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
}
