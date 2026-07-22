//
//  Goals.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 30.06.26.
//

import Foundation
struct LearningGoal: Identifiable, Codable{
    let id: UUID
    var title: String
    var subject: String
    var createdAt: Date
    var isCompleted: Bool
    var notes: String
    
    init(id: UUID = UUID(), title: String, subject: String, createdAt: Date = Date(), isCompleted: Bool = false, notes: String = ""){
        self.id = id
        self.title = title
        self.subject = subject
        self.createdAt = createdAt
        self.isCompleted = isCompleted
        self.notes = notes
    }
}
