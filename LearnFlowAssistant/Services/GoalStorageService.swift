//
//  GoalStorageService.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 03.07.26.
//

import Foundation

final class GoalStorageService{
    private let goalKey = "learning-goals"
    private let sessionKey = "study-sessions"
    
    func save(_ goals: [LearningGoal]){
        do{
            let data = try JSONEncoder().encode(goals)
            UserDefaults.standard.set(data, forKey: goalKey)
        }catch{
            print("Faild to save goals: \(error)")
        }
    }
    
    func load() -> [LearningGoal] {
        guard let data = UserDefaults.standard.data(forKey: goalKey) else {
            return []
        }
        do{
            let goals = try JSONDecoder().decode([LearningGoal].self, from: data)
            return goals
        }catch{
            print("Faild to load goals: \(error)")
            return []
        }
    }
    
    func saveSessions(_ sessions:[StudySession]){
        do{
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: sessionKey)
        }catch {
            print("Faild to save session: \(error)")
        }
    }
    
    func loadSessions() -> [StudySession] {
        guard let data = UserDefaults.standard.data(forKey: sessionKey) else { return [] }
        
        do {
            let sessions = try
            JSONDecoder().decode([StudySession].self, from : data)
            return sessions
            
        } catch{
            print("Faild to load sessions: \(error)")
            return []
        }
    }
}
