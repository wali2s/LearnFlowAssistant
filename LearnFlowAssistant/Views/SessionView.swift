//
//  SessionView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 30.06.26.
//

import SwiftUI

struct SessionView: View {
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        NavigationStack{
            Form{
                Section("Choose Goal"){
                    if viewModel.goals.isEmpty {
                        Text("Please add a goal first")
                            .foregroundStyle(.secondary)
                    }else{
                        Picker("Learning Goal", selection:$viewModel.selectedGoalId){
                            Text("Select a goal")
                                .tag(UUID?.none)
                            ForEach(viewModel.goals){ goal in
                                Text(goal.title).tag(Optional(goal.id))
                            }
                        }
                    }
                }
                Section("Session"){
                    if let start = viewModel.activeSessionStart{
                        Text("Active goal: \(viewModel.currentdGoalTitle)")
                        Text("Started at: \(start.formatted(date: .omitted, time: .shortened))")
                        Button("Stop Session"){
                            viewModel.stopSession()
                        }
                        .foregroundStyle(.red)
                        
                    }else{
                        Text("No active session")
                        Button("Start Session"){
                            viewModel.startSession()
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
