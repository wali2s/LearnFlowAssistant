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
    @State var editedNotes: String
    @State private var hasDeadLine: Bool
    @State private var editedDueDate: Date
    
    init(goal: LearningGoal){
        self.goalId = goal.id
        _editedTitle = State(initialValue: goal.title)
        _editedSubject = State(initialValue: goal.subject)
        _editedNotes = State(initialValue: goal.notes)
        _hasDeadLine = State(initialValue: goal.dueDate != nil)
        _editedDueDate = State(initialValue: goal.dueDate ?? Date())
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
                VStack(alignment: .leading, spacing: 8){
                    Text("Notes")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextEditor(text: $editedNotes)
                        .frame(minHeight: 120)
                }
                
                Toggle("Set deadline", isOn: $hasDeadLine)
                if hasDeadLine {
                    DatePicker(
                        "Deadline",
                        selection: $editedDueDate,
                        displayedComponents: .date
                    )
                }
                Button("save changes"){
                    viewModel.updateGoal(id: goalId, title: editedTitle, subject: editedSubject, notes: editedNotes, dueDate: hasDeadLine ? editedDueDate : nil)
                }
                .disabled(
                    !canSave
                )
            }
            
            Section("Progress") {
                Text("Sessions: \(viewModel.sessionCount(for: goalId))")
                Text("Study Time: \(viewModel.totalStudyTimeText(for: goalId))")
                
                if let dueDate = currentGoal?.dueDate {
                    Text("Deadline: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                    if dueDate < Calendar.current.startOfDay(for: Date()) && !(currentGoal?.isCompleted ?? false){
                        Text("Status: Overdue")
                            .foregroundStyle(.red)            
                    }
                }
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
