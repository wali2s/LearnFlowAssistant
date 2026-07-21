//
//  AchievementsView.swift
//  LearnFlowAssistant
//
//  Created by Wahid on 21.07.26.
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
            NavigationStack {
                List {
                    unlockedSection
                    lockedSection
                }
        }
    }
}

private extension AchievementsView {
    var unlockedSection: some View {
        Section ("Unlocked") {
            if viewModel.unlockedAchievements.isEmpty {
                ContentUnavailableView (
                    "No Achievements Unlocked",
                    systemImage: "rosette",
                    description: Text("Complete sessions and goals to unlock milestones.")
                )
            } else {
                ForEach(viewModel.unlockedAchievements) { achievement in
                    AchievmentRow(for: achievement, unlocked: true)
                }
            }
        }
    }
    
    var lockedSection: some View {
        Section ("Locked") {
            if viewModel.lockedAchievements.isEmpty {
                ContentUnavailableView (
                    "Everythig unlocked",
                    systemImage: "checkmark.seal.fill",
                    description: Text("Great job — you unlocked all current achievements.")
                )
            } else {
                ForEach(viewModel.lockedAchievements) { achievment in
                        AchievmentRow(for: achievment, unlocked: false)
                }
            }
        }
    }
    
    func AchievmentRow(for achievement: Achievement, unlocked: Bool) -> some View {
        HStack( alignment: .top, spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.title3)
                .foregroundStyle(unlocked ? .yellow : .gray)
                .frame(width: 36, height: 36)
                .background((unlocked ? Color.yellow : Color.gray).opacity(0.15)).clipShape(Circle())
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(unlocked ? .primary : .secondary)

                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: unlocked ? "checkmark.circle.fill" : "lock.fill")
                .foregroundStyle(unlocked ? .green : .secondary)
        }
        .padding(.vertical, 3)
        
    }
}

#Preview {
    AchievementsView()
        .environmentObject(AppViewModel())
}
