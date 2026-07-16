//
//  SessionTimerCard.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 16.07.26.
//

import SwiftUI

struct SessionTimerCard: View {
    
    let startDate: Date
    let goalTitle: String
    let formattedDuration: (Int) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12){
            HStack{
                Text("Active Session")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.blue.opacity(0.12))
                    .clipShape(Capsule())
                Spacer()
                
                Image(systemName: "timer")
                    .foregroundStyle(.blue)
            }
            
            VStack(alignment: .leading, spacing: 6){
                Text("Session in Progress")
                    .font(.headline)
                
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let elapsedSeconds = Int(context.date.timeIntervalSince(startDate))
                    
                    Text(formattedDuration(elapsedSeconds))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
            }
            Divider()
            
            VStack(spacing: 10){
                LabeledContent("Goal"){
                    Text(goalTitle)
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Started"){
                    Text(startDate.formatted(date: .abbreviated, time: .shortened))
                        .foregroundStyle(.secondary)
                }
                
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        
    }
}


#Preview {
    SessionTimerCard(
        startDate: .now.addingTimeInterval(-1250),
        goalTitle: "SwiftUI Basics",
        formattedDuration: { seconds in
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes) min \(remainingSeconds) sec"
            
        }
    ).padding()
}
