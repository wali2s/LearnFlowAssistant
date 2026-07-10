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
            ScrollView{
                VStack(alignment: .leading, spacing: 16) {
                    Text("Stattistics")
                        .font(.title.bold())
                    if viewModel.goals.isEmpty {
                        ContentUnavailableView(
                            "No statistics yet",
                            systemImage: "chart.bar",
                            description: Text("Add your first goal to start tracking progress")
                        )
                    }else {
                        summarySection
                        chartSection
                    }
                   
                        
                       
                        
                    }.padding()
                    
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Stats")
        }
    }
    
private extension StatsView {
    var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SummaryCard(title: "Total Goals", value:"\(viewModel.totalGoalCount)", color: .blue)
            SummaryCard(title: "Actie Goals", value: "\(viewModel.activeGoalCount)", color: .orange)
            SummaryCard(title: "Completed Goals", value: "\(viewModel.completedGoalsCount)", color: .green)
            SummaryCard(title: "Total Sessions", value: "\(viewModel.totalSessionCount)", color: .purple)
            SummaryCard(title: "Study Time", value: "\(viewModel.totalStudyTimeText)", color: .pink)
        }
    }
    
    var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Study time per Goal")
                .font(.headline)
            
            if viewModel.goalState.allSatisfy({$0.totalSeconds == 0}){
                ContentUnavailableView(
                    "No study time data",
                    systemImage: "chart.bar",
                    description: Text("Add your first goal to start tracking progress")
                )
            } else {
                Chart(viewModel.goalState){ stat in
                        BarMark(
                            x: .value("Goal", stat.goalTitle),
                            y: .value("Seconds", stat.totalSeconds)
                        )
                        .foregroundStyle(.green.gradient)
                        .cornerRadius(7)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
            
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(17)
    }
}

#Preview {
    StatsView()
        .environmentObject(AppViewModel())
}
