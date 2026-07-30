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
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.goals.isEmpty {
                        ContentUnavailableView(
                            "No statistics yet",
                            systemImage: "chart.bar",
                            description: Text("Add your first goal to start tracking progress")
                        )
                    } else {
                        headerSection
                        overviewSection
                        insightsSection
                        streakSection
                        chartSection
                        achievementsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Stats")
        }
    }
}

private extension StatsView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Statistics")
                .font(.title.bold())
            Text("Track your learning progress across goals and sessions.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
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

    var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Insights")
                .font(.headline)

            HStack {
                SummaryCard(title: "Average Session", value: viewModel.averageSessionDurationText, color: .pink)
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

    var streakSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak")
                .font(.headline)

            HStack(spacing: 12) {
                SummaryCard(title: "Current Streak", value: "\(viewModel.currentStreak) days", color: .orange)
                SummaryCard(title: "Longest Streak", value: "\(viewModel.longestStreak) days", color: .red)
            }
        }
    }

    var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.headline)

            if viewModel.achievements.isEmpty {
                ContentUnavailableView(
                    "No achievements yet",
                    systemImage: "rosette",
                    description: Text("Your unlocked achievements will appear here.")
                )
            } else {
                if !viewModel.unlockedAchievements.isEmpty {
                    Text("Unlocked")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    ForEach(viewModel.unlockedAchievements) { achievement in
                        achievementRow(for: achievement, isUnlocked: true)
                    }
                }

                if !viewModel.lockedAchievements.isEmpty {
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

    @ViewBuilder
    func achievementRow(for achievement: Achievement, isUnlocked: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
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
                    .tint(isUnlocked ? .green : .secondary)
            }

            Spacer()
        }
        .cardStyle()
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

#Preview("Stats with sample data") {
    let viewModel = AppViewModel()

    viewModel.goals = [
        LearningGoal(title: "SwiftUI Basics", subject: "iOS Development", notes: "Learn layout and state"),
        LearningGoal(title: "Combine", subject: "Reactive Programming", notes: "Publishers and subscribers")
    ]

    viewModel.sessions = [
        StudySession(
            id: UUID(),
            goalId: viewModel.goals[0].id,
            goalTitle: viewModel.goals[0].title,
            startedAt: .now.addingTimeInterval(-3600),
            endedAt: .now.addingTimeInterval(-1800),
            durationInSeconds: 1800
        ),
        StudySession(
            id: UUID(),
            goalId: viewModel.goals[1].id,
            goalTitle: viewModel.goals[1].title,
            startedAt: .now.addingTimeInterval(-9000),
            endedAt: .now.addingTimeInterval(-7200),
            durationInSeconds: 1800
        )
    ]

    return StatsView()
        .environmentObject(viewModel)
}
