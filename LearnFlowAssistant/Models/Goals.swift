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
    
    init(id: UUID = UUID(), title: String, subject: String, createdAt: Date = Date()){
        self.id = id
        self.title = title
        self.subject = subject
        self.createdAt = createdAt
    }
}
