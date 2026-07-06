//
//  StatsView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 03.07.26.
//
import SwiftUI

struct StatsView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Statistics")
                    .font(.title.bold())

                Text("Total goals: \(viewModel.goals.count)")
                    .font(.headline)

                if viewModel.goals.isEmpty {
                    Text("No statistics yet. Add your first goal.")
                        .foregroundStyle(.secondary)
                } else {
                    Text("More statistics will come soon.")
                        .foregroundStyle(.secondary)
                }
                
                Text("Total sessions: \(viewModel.sessions.count)")
                    .font(.headline)
    
                Text("Duration is: \(viewModel.sessions.reduce(0) { $0 + $1.duarationInSeconds})")
                    .font(.headline)

                Spacer()
            }
            .padding()
            .navigationTitle("Stats")
        }
    }
}

#Preview {
    StatsView()
        .environmentObject(AppViewModel())
}
