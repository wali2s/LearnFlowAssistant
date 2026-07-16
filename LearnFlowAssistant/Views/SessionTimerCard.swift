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
        VStack(spacing: 12){
            Image(systemName: "Timer")
                .font(.system(size: 28))
                .foregroundStyle(.blue)
            
            Text("Session in Progress")
                           .font(.headline)

                       TimelineView(.periodic(from: .now, by: 1)) { context in
                           let elapsedSeconds = Int(context.date.timeIntervalSince(startDate))

                           Text(formattedDuration(elapsedSeconds))
                               .font(.system(size: 34, weight: .bold, design: .rounded))
                               .monospacedDigit()
                       }

                       Text("Goal: \(goalTitle)")
                           .font(.subheadline)
                           .foregroundStyle(.secondary)
                   }
                   .frame(maxWidth: .infinity)
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
