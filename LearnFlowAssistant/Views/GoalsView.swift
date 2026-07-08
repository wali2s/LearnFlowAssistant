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
                                        .font(.headline)
                                    
                                    Text(goal.subject)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
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
