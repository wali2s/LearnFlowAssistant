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
    @FocusState private var focusedField: Field?
    @State private var goalToDelete: LearningGoal?
    @State private var showDeleteConfirmation: Bool = false
   
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
                    }
                    .disabled(!viewModel.canSave)
                }
                
                Section("My Goals") {
                    
                    Picker("Filter", selection: $viewModel.selectedGoalFilter){
                        ForEach(GoalFilter.allCases){ filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    if viewModel.filteredGoals.isEmpty {
                        if viewModel.goals.isEmpty {
                            ContentUnavailableView("No goals found",
                                                   systemImage: "line.3.horizontal.decrease.circle",
                                                   description: Text("try a different filter or add a new goal")
                            )
                        }else {
                            ContentUnavailableView(
                                "No matching Goals",
                                systemImage: "magnifyingglass",
                                description: Text("Try a different search or filter")
                            )
                        }
                        
                    } else {
                        ForEach(viewModel.filteredGoals) { goal in
                            NavigationLink(destination: GoalDetailView(goal: goal)){
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(goal.title)
                                        .strikethrough(goal.isCompleted)
                                        .foregroundStyle(goal.isCompleted ? .secondary: .primary)
                                    
                                    Text(goal.subject)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false){
                                Button(role: .destructive){
                                    goalToDelete = goal
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    viewModel.toggleGoalCompletion(id: goal.id)
                                } label: {
                                    Label(
                                        goal.isCompleted ? "Mark Active": "Complete",
                                        systemImage: goal.isCompleted ? "arrow.uturn.backward.circle": "checkmark.circle"
                                    )
                                }
                                .tint(goal.isCompleted ? .orange : .green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Goals")
            .searchable(
                text: $viewModel.goalSearchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search goals or subjects"
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Menu {
                        Picker(
                            "Sort Goal",
                            selection: $viewModel.SelectedGoalSort
                        ) {
                            ForEach (GoalSortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
            }
            .confirmationDialog(
                "Delete Goal",
                isPresented: $showDeleteConfirmation ,
                titleVisibility: .visible,
                presenting: goalToDelete
            ) { goal in
                Button("Delete \(goal.title)", role: .destructive) {
                    viewModel.deleteGoal(id: goal.id)
                    goalToDelete = nil
                }

                Button("Cancel", role: .cancel) {
                    goalToDelete = nil
                }
            } message: { goal in
                Text("Are you sure you want to delete \"\(goal.title)\"?")
            }
        }
    }
}

#Preview {
    GoalsView()
        .environmentObject(AppViewModel())
}
