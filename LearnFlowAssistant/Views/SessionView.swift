//
//  SessionView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 30.06.26.
//

import SwiftUI

struct SessionView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    private var selectedGoalTitle: String {
        guard let selectedGoalId = viewModel.selectedGoalId,
              let goal = viewModel.goals.first(where: {$0.id == selectedGoalId})
        else { return "No goal selected" }
        return goal.title
    }
    var body: some View {
        NavigationStack{
            Form{
                Section("Choose Goal"){
                    if viewModel.goals.isEmpty {
                        ContentUnavailableView(
                            "No goal available",
                            systemImage: "target",
                            description: Text("create a goal to start a session")
                        )
                    } else {
                        Picker("Learning Goal", selection:$viewModel.selectedGoalId){
                            Text("Select a goal")
                                .tag(UUID?.none)
                            ForEach(viewModel.goals){ goal in
                                Text(goal.title).tag(Optional(goal.id))
                            }
                        }
                        .disabled(viewModel.activeSessionStart != nil)
                    }
                    
                    LabeledContent(
                        "Selected Goal",
                        value: selectedGoalTitle
                    )
                    .foregroundStyle(viewModel.selectedGoalId == nil ? .secondary : .primary)
                    
                    if viewModel.activeSessionStart != nil{
                        Text("The goal is locked while a sessin is running")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Current Session"){
                    if let startDate = viewModel.activeSessionStart {
                        VStack(spacing: 12){
                            Image(systemName: "timer")
                                .font(.system(size:28))
                                .foregroundStyle(.blue)
                            Text("Session in Progress")
                                .font(.headline)
                            TimelineView(.periodic(from: .now, by: 1)){ context in
                                let elapsedSeconds = Int(context.date.timeIntervalSince(startDate))
                                Text(viewModel.formattedDuration(elapsedSeconds))
                                    .font(.system(size:34,weight: .bold, design: .rounded))
                                    .monospacedDigit()
                            }
                            Text("Goal: \(viewModel.currentGoalTitle)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        Button("Stop Session", role: .destructive){
                            viewModel.stopSession()
                        }
                    }else{
                        VStack(alignment: .leading, spacing: 8){
                            Text("No active session")
                                .font(.headline)
                            Text("Choose a goal and start a focused session")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Button("Start Session"){
                            viewModel.startSession()
                        }
                        .disabled(viewModel.selectedGoalId == nil || viewModel.goals.isEmpty)
                    }
                }
                
                
                Section("Recent Sessions"){
                    if viewModel.sessions.isEmpty {
                        ContentUnavailableView(
                            "No sessions yet",
                            systemImage: "clock",
                            description: Text("Your finished learning session will appear here.")
                        )
                        
                    }else{
                        ForEach(viewModel.recentSessions){ session in
                            VStack(alignment: .leading, spacing: 6){
                                Text(session.goalTitle)
                                    .font(.headline)
                                Text("Duration: \(session.durationText) sec")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(session.formattedStartDate)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Session")
        }
    }
    
}

#Preview {
    SessionView()
        .environmentObject(AppViewModel())
}

