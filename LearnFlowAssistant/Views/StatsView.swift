//
//  StatsView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 03.07.26.
//
import SwiftUI
import Charts
struct StatsView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Statistics")
                    .font(.title.bold())
                
                Text("Total goals: \(viewModel.totalGoalCount)")
                    .font(.headline)
                
                if viewModel.goals.isEmpty {
                    Text("No statistics yet. Add your first goal.")
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment:.leading,spacing: 12){
                        StateRow(title: "Total goals", value: "\(viewModel.totalGoalCount)")
                        StateRow(title: "Total sessions", value: "\(viewModel.totalSessionCount)")
                        StateRow(title: "Total study time", value: "\(viewModel.totalStudyTimeText)")
                        StateRow(title: "Active goal", value: "\(viewModel.activeGoalCount)")
                        StateRow(title:"Completed goals", value: "\(viewModel.completedGoalsCount)")
                        
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Per goal")
                        .font(.headline)
                        
                    if viewModel.goalState.allSatisfy({$0.totalSeconds == 0}){
                        ContentUnavailableView(
                            "no study date yet",
                            systemImage: "chart.bar",
                            description: Text("Complete a study session to see your chart")
                        
                        )
                        
                    }
                    
                    Chart(viewModel.goalState) { stat in
                        BarMark(
                            x: .value("Goal", stat.goalTitle),
                            y: .value("Seconds", stat.totalSeconds)
                        )
                        .foregroundStyle(.green)
                    }
                    .frame(height: 200)
                    
                }.padding(.top, 12)
                
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Stats")
    }
}

struct StateRow: View {
    let title: String
    let value: String
    
    
    var body: some View{
        HStack{
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    StatsView()
        .environmentObject(AppViewModel())
}
