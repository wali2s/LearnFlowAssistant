//
//  RecentSessionRoa.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 16.07.26.
//

import SwiftUI

struct RecentSessionRow: View {
    let session: StudySession
    var body: some View {
        
        HStack(alignment: .top, spacing: 12){
            Image(systemName: "clock.fill")
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width:36, height: 36)
                .background(.blue.opacity(0.12))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 8){
                HStack(alignment: .firstTextBaseline){
                    Text(session.goalTitle)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Text(session.durationText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.blue.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                Text(session.formattedStartDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

#Preview {
    RecentSessionRow(session: StudySession(id: UUID(), goalId: UUID(), goalTitle: "SwiftUI Layout", startedAt: .now.addingTimeInterval(-36000), endedAt: .now, durationInSeconds: 1800))
}
