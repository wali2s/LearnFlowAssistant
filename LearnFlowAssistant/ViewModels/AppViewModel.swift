import Foundation
import Combine
import SwiftUI

enum GoalFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
    
    var id: String { rawValue }
}

enum GoalSortOption: String, CaseIterable, Identifiable {
    case titleAscending = "Title: A-Z"
    case titleDescending = "Title: Z-A"
    case activeFirst = "Active First"
    case completedFirst = "Completed First"
    
    var id: String { rawValue }
}

struct SessionSection: Identifiable {
    let date : Date
    let sessions: [StudySession]
    
    var id: Date { date }
    
    var title: String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(date : .abbreviated, time: .omitted)
        }
    }
}


final class AppViewModel: ObservableObject {
    @Published var goals: [LearningGoal] = []
    @Published var title: String = ""
    @Published var subject: String = ""
    @Published var canSave: Bool = false

    @Published var sessions: [StudySession] = []
    @Published var selectedGoalId: UUID?
    @Published var activeSessionStart: Date?
    @Published var currentGoalTitle: String = ""
    
    @Published var selectedGoalFilter: GoalFilter = .all
    @Published var selectedGoalSort: GoalSortOption = .titleAscending
    
    @Published var goalSearchText: String = ""

    private var cancellables = Set<AnyCancellable>()
    private let storage = GoalStorageService()

    init() {
        goals = storage.load()
        sessions = storage.loadSessions()

        Publishers.CombineLatest($title, $subject)
            .map { title, subject in
                !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .assign(to: &$canSave)

        $goals
            .sink { [weak self] goals in
                self?.storage.save(goals)
            }
            .store(in: &cancellables)

        $sessions
            .sink { [weak self] sessions in
                self?.storage.saveSessions(sessions)
            }
            .store(in: &cancellables)
    }

    func addGoal() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSubject = subject.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty, !trimmedSubject.isEmpty else { return }

        let goal = LearningGoal(title: trimmedTitle, subject: trimmedSubject)
        goals.append(goal)

        title = ""
        subject = ""
    }

    func deleteGoal(id: UUID) {
        goals.removeAll { $0.id == id }
    }

    func updateGoal(id: UUID, title: String, subject: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSubject = subject.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty, !trimmedSubject.isEmpty else { return }
        guard let index = goals.firstIndex(where: { $0.id == id }) else { return }

        goals[index].title = trimmedTitle
        goals[index].subject = trimmedSubject
    }

    func toggleGoalCompletion(id: UUID) {
        guard let index = goals.firstIndex(where: { $0.id == id }) else { return }
        goals[index].isCompleted.toggle()
    }

    func startSession() {
        guard activeSessionStart == nil else { return }
        guard let selectedGoalId,
              let goal = goals.first(where: { $0.id == selectedGoalId }) else { return }

        activeSessionStart = Date()
        currentGoalTitle = goal.title
    }

    func stopSession() {
        guard let selectedGoalId,
              let goal = goals.first(where: { $0.id == selectedGoalId }),
              let start = activeSessionStart else { return }

        let end = Date()
        let duration = Int(end.timeIntervalSince(start))

        let session = StudySession(
            id: UUID(),
            goalId: goal.id,
            goalTitle: goal.title,
            startedAt: start,
            endedAt: end,
            durationInSeconds: duration
        )

        sessions.insert(session, at: 0)
        activeSessionStart = nil
        currentGoalTitle = ""
    }
    
    func deleteSession(_ session: StudySession) {
        sessions.removeAll {$0.id == session.id}
    }
}

extension AppViewModel {
    var totalGoalCount: Int {
        goals.count
    }

    var activeGoalCount: Int {
        goals.filter { !$0.isCompleted }.count
    }

    var completedGoalsCount: Int {
        goals.filter { $0.isCompleted }.count
    }

    var totalSessionCount: Int {
        sessions.count
    }

    var totalStudySeconds: Int {
        sessions.reduce(0) { $0 + $1.durationInSeconds }
    }

    var totalStudyTimeText: String {
        let hours = totalStudySeconds / 3600
        let minutes = (totalStudySeconds % 3600) / 60
        let seconds = totalStudySeconds % 60

        if hours > 0 {
            return "\(hours) h \(minutes) min \(seconds) sec"
        } else if minutes > 0 {
            return "\(minutes) min \(seconds) sec"
        } else {
            return "\(seconds) sec"
        }
    }
    
    func formattedDuration(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var recentGoals: [LearningGoal] {
        Array(goals.prefix(3))
    }

    var recentSessions: [StudySession] {
        Array(sessions.prefix(5))
    }
    
    var goalState: [GoalState] {
        goals.map { goal in
            let matchingSessions = sessions.filter{
                $0.goalId == goal.id
            }
            let totalSeconds = matchingSessions.reduce (0) {
                $0 + $1.durationInSeconds
            }
            
            return GoalState(goalTitle: goal.title, sessionCount: matchingSessions.count, totalSeconds: totalSeconds)
        }
    }
    
    var sortedGoalStats: [GoalState] {
        goalState
            .filter { $0.totalSeconds > 0}
            .sorted { $0.totalSeconds > $1.totalSeconds}
    }
    
    var filteredGoals: [LearningGoal] {
        let statusFilteredGoals: [LearningGoal]
        
        switch selectedGoalFilter {
        case .all:
            statusFilteredGoals = goals
        case .active:
            statusFilteredGoals = goals.filter { !$0.isCompleted }
        case .completed:
            statusFilteredGoals = goals.filter { $0.isCompleted }
        }
        
        let trimmedSearchText = goalSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var searchedGoals: [LearningGoal]
        if trimmedSearchText.isEmpty {
            searchedGoals = statusFilteredGoals
        }else {
            searchedGoals = statusFilteredGoals
                .filter{ goal in
                    goal.title.localizedStandardContains(trimmedSearchText) ||
                    goal.subject.localizedStandardContains(trimmedSearchText)
                }
        }
        
        switch selectedGoalSort {
            
        case .titleAscending:
            return searchedGoals.sorted{
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        case .titleDescending:
            return searchedGoals.sorted{
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending
            }
        case .activeFirst:
            return searchedGoals.sorted { lhs, rhs in
                if lhs.isCompleted == rhs.isCompleted {
                    return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                }
                return !lhs.isCompleted && rhs.isCompleted
            }

        case .completedFirst:
            return searchedGoals.sorted { lhs, rhs in
                if lhs.isCompleted == rhs.isCompleted {
                    return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                }
                return lhs.isCompleted && !rhs.isCompleted
            }
        }
    }
    var groupedRecentSessions: [SessionSection] {
        let grouped = Dictionary(grouping: recentSessions) { session in
            Calendar.current.startOfDay(for: session.startedAt)
        }
        
        return grouped.map { date, sessions in
            SessionSection(
                date: date,
                sessions: sessions.sorted {$0.startedAt > $1.startedAt}
            )
        }.sorted { $0.date > $1.date }
    }
    
    var chartGoalStats: [GoalState] {
        return goalState.filter {$0.totalSeconds > 0}
    }
}
