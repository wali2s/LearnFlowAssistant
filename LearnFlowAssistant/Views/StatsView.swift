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
                        streakSection
                        chartSection
                        achievementsSection
                    }
                }
                .padding()
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
    
    var streakSection : some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak")
                .font(.headline)
            
            HStack(spacing: 12) {
                SummaryCard(title: "Current Streak", value: "\(viewModel.currentStreak) days", color: .orange)
                SummaryCard(title: "Longest Streak", value: "\(viewModel.longestStreak) days", color: .red)
            }
        }
    }
    
    @ViewBuilder
    private func achievementRow(for achievement: Achievement, isUnlocked: Bool) -> some View {
            HStack (alignment: .top, spacing: 12) {
                Image(systemName: achievement.icon)
                    .font(.title3)
                    .foregroundStyle(isUnlocked ? .yellow : .gray)
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(achievement.title)
                            .font(.headline)
                        
                        if isUnlocked {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(achievement.progressText)
                        .font(.caption)
                        .foregroundStyle(isUnlocked ? .green : .secondary)
                    
                    ProgressView(value: achievement.progress)
                        .tint( isUnlocked ? .green : .secondary)
                }
                
                Spacer()
            }
            .cardStyle()
        }
        
    var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
            
            if viewModel.achievements.isEmpty {
                ContentUnavailableView(
                    "No achievements yet",
                    systemImage: "rosette",
                    description: Text("Your unloced achievements will apear here.")
                )
            } else{
                if !viewModel.unlockedAchievements.isEmpty {
                    Text("Unlocked")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    
                    ForEach(viewModel.unlockedAchievements) { achievement in
                        achievementRow(for: achievement, isUnlocked: true)
                    }
                }
                
                if !viewModel.lockedAchievements.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("In Progress")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        ForEach(viewModel.lockedAchievements) { achievement in
                            achievementRow(for: achievement, isUnlocked: false)
                        }
                    }
                }
            }
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
