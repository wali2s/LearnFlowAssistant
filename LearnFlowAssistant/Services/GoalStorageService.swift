//
//  GoalStorageService.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 03.07.26.
//

import Foundation

final class GoalStorageService{
    private let key = "learning-goals"
    
    func save(_ goals: [LearningGoal]){
        do{
            let data = try JSONEncoder().encode(goals)
            UserDefaults.standard.set(data, forKey: key)
        }catch{
            print("Faild to save goals: \(error)")
        }
    }
    
    func load() -> [LearningGoal] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
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
}
