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
                   
                    if viewModel.goals.isEmpty {
                        ContentUnavailableView(
                            "No statistics yet",
                            systemImage: "chart.bar",
                            description: Text("Add your first goal to start tracking progress")
                        )
                    }else {
                        headerSection
                        overviewSection
                        insightsSections
                        chartSection
                    }
                   
                        
                       
                        
                    }.padding()
                    
                }
            }
            .padding()
            .navigationTitle("Stats")
        }
    }
    
private extension StatsView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Statistics").font(.title.bold())
            Text("Track your learning progress across goals and sessions.").font(.subheadline)
        }
    }
    var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                           .font(.headline)

                       HStack {
                           SummaryCard(title: "Goals", value: "\(viewModel.totalGoalCount)", color: .blue)
                           SummaryCard(title: "Sessions", value: "\(viewModel.totalSessionCount)", color: .green)
                       }

                       HStack {
                           SummaryCard(title: "Study Time", value: viewModel.totalStudyTimeText, color: .orange)
                           SummaryCard(title: "Active", value: "\(viewModel.activeGoalCount)", color: .purple)
                       }
        }
    }
    
    var insightsSections: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Insights")
                .font(.headline)
            
            HStack {
                SummaryCard(title: "Average Session", value: viewModel.avarageSessinDurationText, color: .pink)
                SummaryCard(title: "Longest Session", value: viewModel.longestSessionText, color: .red)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Top Goal")
                                    .font(.subheadline.weight(.semibold))

                                Text(viewModel.mostProductiveGoalTitle)
                                    .font(.headline)

                                Text("Study Time: \(viewModel.mostProductiveGoalTimeText)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
            
        }
    }
    
    var chartSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Study Time per Goal")
                    .font(.headline)

                if viewModel.chartGoalStats.isEmpty {
                    ContentUnavailableView(
                        "No chart data yet",
                        systemImage: "chart.bar",
                        description: Text("Complete some study sessions to see your chart.")
                    )
                } else {
                    Chart(viewModel.sortedGoalStats) { stat in
                        let minutes = Double(stat.totalSeconds) / 60

                        BarMark(
                            x: .value("Goal", stat.goalTitle),
                            y: .value("Minutes", minutes)
                        )
                        .foregroundStyle(color(totalSeconds: stat.totalSeconds))
                        .cornerRadius(7)
                        .annotation(position: .top) {
                            Text("\(minutes, specifier: "%.0f") min")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        RuleMark(y: .value("Average", viewModel.averageStudyMinutesPerGoal))
                            .foregroundStyle(.blue)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [4]))
                            .annotation(position: .top, alignment: .trailing) {
                                Text("Avg \(viewModel.averageStudyMinutesPerGoal, specifier: "%.0f") min")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                    }
                    .frame(height: 220)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
            }
        }
    
    func color(totalSeconds: Int) -> Color {
        
        switch totalSeconds {
        case 0..<30:
            return .red
        case 30..<60:
            return .orange
        case 60..<120:
            return .yellow
        default:
            return .green
        }
    }
}

#Preview {
    StatsView()
        .environmentObject(AppViewModel())
}

extension AppViewModel {
    var averageStudyMinutesPerGoal: Double {
        let statsWithStudyTime = goalState.filter { $0.totalSeconds > 0}
        
        guard !statsWithStudyTime.isEmpty else { return 0}
        
        let totalMinutes = statsWithStudyTime
            .map { Double( $0.totalSeconds) / 60.0 }
            .reduce(0, +)
        
        return totalMinutes / Double(statsWithStudyTime.count)
    }
}
