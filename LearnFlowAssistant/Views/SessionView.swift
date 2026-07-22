//
//  SessionView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 30.06.26.
//

import SwiftUI

struct SessionView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showStopConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var sessionToDelete: StudySession?
    @State private var showPomodoroFinishedAlert = false
    
    private var selectedGoalTitle: String {
        guard let selectedGoalId = viewModel.selectedGoalId,
              let goal = viewModel.goals.first(where: {$0.id == selectedGoalId})
        else { return "No goal selected" }
        return goal.title
    }
    var body: some View {
        NavigationStack{
            Form{
                sessionModeSection
                goalPickerSection
                currentSessionSection
                recentSessionsSection
            }
            .formStyle(.grouped)
            .navigationTitle("Session")
            .confirmationDialog(
                "Stop Session",
                isPresented: $showStopConfirmation,
                titleVisibility: .visible
            ){
                Button("Stop Session", role: .destructive){
                    viewModel.stopSession()
                }
                
                Button("Cancel", role: .cancel){
                    
                }
            }message: {
                Text("Are you sure you want to stop the session?")
            }
            .confirmationDialog(
                "Delete Session",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ){
                Button("Delete Session", role: .destructive){
                    
                    if let session = sessionToDelete {
                        viewModel.deleteSession(session)
                        sessionToDelete = nil
                    }
                }
                Button ("Cancel", role: .cancel){
                    sessionToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this session?")
            }
        }
        .alert("Pmodoro Finshed", isPresented: $showPomodoroFinishedAlert){
            Button("OK", role: .cancel){}
        }message: {
            Text("Your focus session has ended.")
        }
        .onChange(of: viewModel.didFinishPomodoro) { didNotFinish, didFinish in
            if didFinish {
                showPomodoroFinishedAlert = true
                viewModel.didFinishPomodoro = false
            }
        }
    }
}

extension SessionView {
    
    private var sessionModeSection: some View {
        Section("Session Mode") {
            Picker("Mode", selection: $viewModel.selectSessionMode) {
                ForEach(SessionMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .disabled(viewModel.activeSessionStart != nil)
            
            if viewModel.selectSessionMode == .pomodoro {
                Picker("Focus Length", selection: $viewModel.pomodoroFocusMinutes) {
                    ForEach (viewModel.pomodoroMinutesOptions, id: \.self) {
                        minutes in
                        Text("\(minutes) min").tag(minutes)
                    }
                }
            }
        }
        
    }
    
    private var goalPickerSection : some View {
        Section("Choose Goal"){
            if !viewModel.hasSelectableGoal {
                ContentUnavailableView(
                    "No goal available",
                    systemImage: "target",
                    description: Text("create a goal to start a session")
                )
            } else {
                Picker("Learning Goal", selection:$viewModel.selectedGoalId){
                    Text("Select a goal")
                        .tag(UUID?.none)
                    ForEach(viewModel.activeGoals){ goal in
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
    }
    
    private var currentSessionSection: some View {
        Section("Current Session"){
            if let startDate = viewModel.activeSessionStart {
                SessionTimerCard(startDate: startDate, goalTitle: viewModel.currentGoalTitle, formattedDuration: viewModel.formattedDuration)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                LabeledContent(
                    "Mode",
                    value: viewModel.selectSessionMode.rawValue
                )
                .font(.subheadline)
                if viewModel.selectSessionMode == .pomodoro {
                    LabeledContent(
                        "Remaining Focus Time",
                        value: viewModel.formattedDuration(viewModel.pomodoroRemainingSeconds))
                    .font(.headline)
                }
                
                Button("Stop Session", role: .destructive){
                    showStopConfirmation = true
                }
            }else{
                VStack(alignment: .leading, spacing: 8){
                    Text("No active session")
                        .font(.headline)
                    if viewModel.selectSessionMode == .pomodoro {
                        Text("Pomodoro mode is active. Your Focus session will run for \(viewModel.pomodoroFocusMinutes) minutes.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Choose a goal and start a focused session.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
               
                Button(viewModel.selectSessionMode == .pomodoro ? "Start Pomodoro" : "Start Session"){
                    viewModel.startSession()
                }
                .disabled(viewModel.selectedGoalId == nil || !viewModel.hasSelectableGoal)
            }
        }
    }
    
    private var recentSessionsSection: some View {
        Section("Recent Sessions"){
            if viewModel.sessions.isEmpty {
                ContentUnavailableView(
                    "No sessions yet",
                    systemImage: "clock",
                    description: Text("Your finished learning session will appear here.")
                )
                .listRowSeparator(.hidden)
                
            }else{
                ForEach(viewModel.groupedRecentSessions) { section in
                    Section(section.title) {
                        ForEach(section.sessions) { session in
                            NavigationLink {
                                SessionDetailView(session: session)
                            } label: {
                                RecentSessionRow(session: session)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    sessionToDelete = session
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listSectionSeparator(.hidden)
                }
            }
        }
    }
}


#Preview {
    SessionView()
        .environmentObject(AppViewModel())
}

