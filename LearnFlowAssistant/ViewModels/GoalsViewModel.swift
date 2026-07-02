//
//  GoalsViewModel.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 30.06.26.
//

import Foundation
import Combine
import SwiftUI

final class GoalsViewModel: ObservableObject {
    @Published var goals: [LearningGoal] = []
    @Published var title: String = ""
    @Published var subject: String = ""
    @Published var canSave: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest($title,$subject)
            .map{ title, subject in
                !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .assign(to: &$canSave)
    }
    
    func addGoal(){
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSubject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty, !trimmedSubject.isEmpty else { return }
        let goal = LearningGoal(title: trimmedTitle, subject: trimmedSubject)
        goals.append(goal)
        
        title = ""
        subject = ""
    }
    
    func deleteGoal(at offsets: IndexSet) {
            goals.remove(atOffsets: offsets)
        }
}
