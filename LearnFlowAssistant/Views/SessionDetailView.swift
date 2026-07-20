//
//  SessionDetailView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 20.07.26.
//

import SwiftUI

struct SessionDetailView: View {
    let session: StudySession
    
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
