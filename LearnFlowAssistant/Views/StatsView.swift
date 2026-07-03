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
