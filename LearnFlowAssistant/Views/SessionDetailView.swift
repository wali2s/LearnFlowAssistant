//
//  SessionDetailView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 20.07.26.
//

import SwiftUI

struct SessionDetailView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var editedNote: String
    @State private var showSavedFeedback = false
    let session: StudySession
    init(session: StudySession) {
        self.session = session
        _editedNote = State(initialValue: session.notes ?? "")
    }
    var body: some View {
        List {
            Section("Session Info") {
                LabeledContent("Goal") {
                    Text(session.goalTitle)
                }
                LabeledContent("Duration") {
                    Text(session.durationText)
                }
            }
            
            Section("Time") {
                LabeledContent("Started") {
                    Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                }
                
                if let endedAt = session.endedAt {
                    LabeledContent("Ended") {
                        Text(endedAt.formatted(date: .abbreviated, time: .shortened))
                    }
                } else {
                    LabeledContent("Ended") {
                        Text("Still in progress")
                            .foregroundStyle(.secondary)
                    }
                }
               
            }
            
            Section("Notes") {
                TextEditor(text: $editedNote)
                    .frame(height: 140)
                
                Button("Sava Notes") {
                    viewModel.updateSession(id: session.id, notes: editedNote)
                    withAnimation {
                        showSavedFeedback = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                        withAnimation {
                            showSavedFeedback = false
                        }
                    }
                }
                
                if showSavedFeedback {
                    Label(
                        "Notes saved",
                        systemImage: "checkmark.circle",
                    )
                    .font(.callout)
                    .foregroundStyle(.green)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            
            
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(
            session: StudySession(
                id: UUID(),
                goalId: UUID(),
                goalTitle: "SwiftUI Charts",
                startedAt: .now.addingTimeInterval(-2400),
                endedAt: .now,
                durationInSeconds: 2400
               
            ))
    }
}
