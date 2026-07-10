import Foundation
import Combine
import SwiftUI

enum GoalFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
    
    var id: String { rawValue }
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

    func deleteGoal(at offsets: IndexSet) {
        goals.remove(atOffsets: offsets)
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
    
    var filteredGoals: [LearningGoal] {
        switch selectedGoalFilter {
        case .all:
            return goals
        case .active:
            return goals.filter { !$0.isCompleted }
        case .completed:
            return goals.filter { $0.isCompleted }
        }
    }
    
    var sortedGoalStats: [GoalState] {
        goalState
            .filter { $0.totalSeconds > 0}
            .sorted { $0.totalSeconds > $1.totalSeconds}
    }
}
