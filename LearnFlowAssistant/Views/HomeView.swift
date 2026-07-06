//
//  HomeView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 30.06.26.
//
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Welcome back")
                    .font(.title.bold())

                Text("You have \(viewModel.goals.count) learning goals.")
                    .font(.headline)
                
                Text("You have completed \(viewModel.sessions.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if viewModel.goals.isEmpty {
                    Text("Start by adding your first goal in the Goals tab.")
                        .foregroundStyle(.secondary)
                } else {
                    List(viewModel.goals.prefix(3)) { goal in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(goal.title)
                                .font(.headline)

                            Text(goal.subject)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppViewModel())
}
