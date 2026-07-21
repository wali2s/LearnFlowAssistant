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
    
    private var goalSessions: [StudySession] {
        viewModel.sessions(for: goalId)
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
            
            Section("Progress") {
                Text("Sessions: \(viewModel.sessionCount(for: goalId))")
                Text("Study Time: \(viewModel.totalStudyTimeText(for: goalId))")
            }
            
            Section("Recent Sessions") {
                if goalSessions.isEmpty {
                    ContentUnavailableView (
                        "No sessions yet",
                        systemImage: "clock",
                        description: Text("Start your first session for this goal")
                    )
                } else {
                    ForEach( goalSessions.prefix(5)){ session in
                        NavigationLink {
                            SessionDetailView(session: session)
                        } label: {
                            RecentSessionRow (session: session)
                        }
                    }
                }
            }
            
        }
        .navigationTitle("Goal Detail")
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(goal: LearningGoal(title: "Learn Swift", subject: "Swift"))
            .environmentObject(AppViewModel())
    }
    
}
