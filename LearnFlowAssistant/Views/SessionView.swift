//
//  SessionView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 30.06.26.
//

import SwiftUI

struct SessionView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isLearning = false
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
                    }else if viewModel.selectedGoalId == nil{
                            ContentUnavailableView(
                                "No goal selected",
                                systemImage: "checklist",
                                description: Text("Choose a goal to start your learning session")
                            )
                    } else if isLearning{
                        ContentUnavailableView(
                            "Active goal \(viewModel.currentGoalTitle)",
                            systemImage: "pause.fill",
                            description: Text("You are currently learning \(viewModel.currentGoalTitle)")
                        )
                    } else {
                        ContentUnavailableView(
                            "Click Start Session to learn ",
                            systemImage: "checkmark",
                            description: Text("")
                        )
                    }
                    

                        Picker("Learning Goal", selection:$viewModel.selectedGoalId){
                            Text("Select a goal")
                                .tag(UUID?.none)
                            ForEach(viewModel.goals){ goal in
                                Text(goal.title).tag(Optional(goal.id))
                            }
                        }
                    }
                
                Section("Session"){
                    if let start = viewModel.activeSessionStart{
                        
                        Button("Stop Session"){
                            viewModel.stopSession()
                            isLearning = false
                        }
                        .foregroundStyle(.red)
                        
                    }else{
                        Text("No active session")
                        Button("Start Session"){
                            viewModel.startSession()
                            isLearning = true
                        }
                        .disabled(viewModel.selectedGoalId == nil || viewModel.goals.isEmpty)
                    }
                }
                
                Section("Recent Session"){
                    if viewModel.sessions.isEmpty {
                        Text("No sessions yet")
                            .foregroundStyle(.secondary)
                        
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
