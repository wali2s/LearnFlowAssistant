//
//  GoalsView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 30.06.26.
//
import SwiftUI
import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var selectedTab: AppTab
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title
        case subject
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("New Goal") {
                    TextField("Goal title", text: $viewModel.title)
                        .focused($focusedField, equals: .title)
                    TextField("Subject", text: $viewModel.subject)
                        .focused($focusedField, equals: .subject)

                    Button("Add Goal") {
                        viewModel.addGoal()
                        focusedField = nil
                        selectedTab = .home
                    }
                    .disabled(!viewModel.canSave)
                }

                Section("My Goals") {
                    if viewModel.goals.isEmpty {
                        Text("No goals yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.goals) { goal in
                            NavigationLink(destination: GoalDetailView(goal: goal)){
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(goal.title)
                                        .strikethrough(goal.isCompleted)
                                        .foregroundStyle(goal.isCompleted ? .secondary: .primary)
                                    
                                    Text(goal.subject)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button{
                                    viewModel.toggleGoalCompletion(id: goal.id)
                                } label: {
                                    Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(goal.isCompleted ? .green : .gray)
                                        .font(.title3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .onDelete(perform: viewModel.deleteGoal)
                    }
                }
            }
            .navigationTitle("Goals")
        }
    }
}

#Preview {
    GoalsView(selectedTab: .constant(.goals))
        .environmentObject(AppViewModel())
}
