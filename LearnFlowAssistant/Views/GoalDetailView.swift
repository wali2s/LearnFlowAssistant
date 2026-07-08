//
//  GoalDetailView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 06.07.26.
//

import SwiftUI

struct GoalDetailView: View {
    
    @EnvironmentObject var viewModel: AppViewModel
    let goalId: UUID
    @State var editedTitle: String
    @State var editedSubject: String
    
    init(goal: LearningGoal){
        self.goalId = goal.id
        _editedTitle = State(initialValue: goal.title)
        _editedSubject = State(initialValue: goal.subject)
    }
    
    private var currentGoal: LearningGoal?{
        viewModel.goals.first(where: {$0.id == goalId})
    }
    
    private var canSave: Bool{
        !editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !editedSubject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var body: some View {
        Form{
            Section("Edit Goal"){
                TextField("Goal title", text:$editedTitle)
                TextField("Goal subject", text: $editedSubject)
                Button("save changes"){
                    viewModel.updateGoal(id: goalId, title: editedTitle, subject: editedSubject)
                }
                .disabled(
                    !canSave
                )
            }
            if let goal = currentGoal{
                Section("Goal detail"){
                    Text("Title: \(goal.title)")
                    Text("Subject: \(goal.subject)")
                    Text("Created: \(goal.createdAt.formatted(date: .abbreviated, time: .shortened))")
                }
            }
        }
        .navigationTitle("Goal Detail")
    }
}

#Preview {
    GoalDetailView(goal: LearningGoal(title: "", subject: ""))
        .environmentObject(AppViewModel())
}
