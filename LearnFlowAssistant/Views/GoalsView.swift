//
//  GoalsView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 30.06.26.
//

import SwiftUI

struct GoalsView: View {
    @StateObject private var viewModel = GoalsViewModel()
    
    var body: some View {
        VStack{
            Form{
                Section("New Goal"){
                    TextField("Goal title", text: $viewModel.title)
                    TextField("Subject", text:$viewModel.subject)
                    
                    Button("Add Goal"){
                        viewModel.addGoal()
                    }
                    .disabled(!viewModel.canSave)
                }
                Section("My Goals"){
                    if viewModel.goals.isEmpty{
                        Text("No Goals yet")
                            .foregroundStyle(.secondary)
                    }else{
                        List{
                            ForEach(viewModel.goals){ goal in
                                VStack(alignment: .leading, spacing: 5){
                                    Text(goal.title)
                                        .font(.headline)
                                    Text(goal.subject)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }.onDelete(perform: viewModel.deleteGoal)
                        }
                    }
                }
            }.navigationTitle("Golas")
        }
    }
}
#Preview {
    GoalsView()
}
