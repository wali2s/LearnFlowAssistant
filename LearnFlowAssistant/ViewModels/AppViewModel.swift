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

enum SessionMode: String,CaseIterable, Identifiable {
    case free = "Free Session"
    case pomodoro = "Pomodoro"
    
    var id : String { rawValue }
}

final class AppViewModel: ObservableObject {
    @Published var goals: [LearningGoal] = []
    @Published var title: String = ""
    @Published var subject: String = ""
    @Published var canSave: Bool = false
    @Published var notes: String = ""
    
    @Published var sessions: [StudySession] = []
    @Published var selectedGoalId: UUID?
    @Published var activeSessionStart: Date?
    @Published var currentGoalTitle: String = ""
    @Published var selectSessionMode: SessionMode = .free
    @Published var pomodoroFocusMinutes: Int = 25
    @Published var pomodoroRemainingSeconds: Int = 0
    
    @Published var selectedGoalFilter: GoalFilter = .all
    @Published var selectedGoalSort: GoalSortOption = .titleAscending
    
    @Published var goalSearchText: String = ""
    @Published var didFinishPomodoro: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let storage = GoalStorageService()
    let pomodoroMinutesOptions: [Int] = [1,15, 25, 30, 45, 60]
    private var pomodoroTimer: Timer?
    


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
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty, !trimmedSubject.isEmpty else { return }

        let goal = LearningGoal(title: trimmedTitle, subject: trimmedSubject, notes: trimmedNotes)
        goals.append(goal)

        title = ""
        subject = ""
        notes = ""
    }

    func deleteGoal(id: UUID) {
        goals.removeAll { $0.id == id }
        
        if selectedGoalId == id {
            selectedGoalId = nil
        }
        
        if currentGoalTitle.isEmpty == false, goals.first(where: { $0.id == id}) == nil, activeSessionStart == nil {
            currentGoalTitle = ""
        }
        sanitizeSelectedGoal()
    }

    func updateGoal(id: UUID, title: String, subject: String, notes: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSubject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty, !trimmedSubject.isEmpty else { return }
        guard let index = goals.firstIndex(where: { $0.id == id }) else { return }

        goals[index].title = trimmedTitle
        goals[index].subject = trimmedSubject
        goals[index].notes = trimmedNotes
    }

    func toggleGoalCompletion(id: UUID) {
        guard let index = goals.firstIndex(where: { $0.id == id }) else { return }
        goals[index].isCompleted.toggle()
        
        sanitizeSelectedGoal()
    }

    func startSession() {
        sanitizeSelectedGoal()
        didFinishPomodoro = false
        guard activeSessionStart == nil else { return }
        guard let selectedGoalId,
              let goal = activeGoals.first(where: { $0.id == selectedGoalId }) else { return }

        activeSessionStart = Date()
        currentGoalTitle = goal.title
        
        if selectSessionMode == .pomodoro {
            pomodoroRemainingSeconds = pomodoroFocusMinutes * 60
            
            startPomodoroTimer()
        }
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
        self.selectedGoalId = nil
        pomodoroRemainingSeconds = 0
        pomodoroTimer?.invalidate()
        pomodoroTimer = nil
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
    
    func sessions(for goalId: UUID) -> [StudySession] {
        return sessions
            .filter { $0.goalId == goalId }
            .sorted { $0.startedAt > $1.startedAt }
    }
    
    func sessionCount(for goalId: UUID) -> Int {
        sessions(for: goalId).count
    }
    
    func totalStudyTimeText(for goalId: UUID) -> String {
        let totalSeconds = sessions(for: goalId).reduce(0) { $0 + $1.durationInSeconds }
        return formattedDuration(totalSeconds)
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
    
    var activeGoals: [LearningGoal] {
        return goals.filter { !$0.isCompleted }
    }
    
    var longestSession: StudySession? {
        sessions.max(by: {$0.durationInSeconds < $1.durationInSeconds})
    }
    
    var longestSessionText: String {
        guard let longestSession else { return "0 sec" }
        return longestSession.durationText
    }
    
    var avarageSessinDurationText: String {
        guard !sessions.isEmpty else { return "0 sec" }
        
        let avarageSeconds = totalStudySeconds / sessions.count
        let hour = avarageSeconds / 3600
        let minutes = (avarageSeconds % 3600) / 60
        let seconds = avarageSeconds % 60
        
        if hour > 0 {
            return "\(hour) h \(minutes) min \(seconds) sec"
        } else if minutes > 0 {
            return "\(minutes) min \(seconds) sec"
        } else {
            return "\(seconds) sec"
        }
    }
    
    var mostProductiveGoalTitle: String {
        sortedGoalStats.first?.goalTitle ?? "No data"
    }
    
    var mostProductiveGoalTimeText: String {
        sortedGoalStats.first?.totalTimeText ?? "0 sec"
    }
    
    var totalStudyMinutes: Double {
        Double(totalStudySeconds) / 60.0
    }
    
    var studyDays: [Date] {
        let calendar = Calendar.current

        let uniqueDays = Set(
            sessions.map { calendar.startOfDay(for: $0.startedAt) }
        )

        return uniqueDays.sorted()
    }
    var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let days = Set(studyDays)
        
        guard days.contains(today) || days.contains(yesterday) else {
            return 0
        }
        
        var streak = 0
        
        var currentDay = days.contains(today) ? today : yesterday
        
        while days.contains(currentDay) {
            streak += 1
            guard let previosDay = calendar.date(byAdding: .day, value: -1, to: currentDay) else {
                return streak
            }
            
            currentDay = previosDay
        }
        return streak
    }
    
    var longestStreak: Int {
        let calendar = Calendar.current
        let days = studyDays
        
        guard !days.isEmpty else { return 0 }
        guard days.count > 1 else { return 1 }
        
        var longest = 1
        var current = 1
        
        for index in 1..<days.count {
            let previosDay = days[index - 1]
            let currentDay = days[index]
            
            if let expectedNextDay = calendar.date(byAdding: .day, value: 1, to: previosDay), calendar.isDate(expectedNextDay, inSameDayAs: currentDay) {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
            
        }
        return longest

    }
    
    var achievements: [Achievement] {
        [
            Achievement(
                       title: "First Session",
                       description: "Complete your first study session",
                       icon: "play.circle.fill",
                       currentValue: totalSessionCount,
                       targetValue: 1,
                       progressText: "\(min(totalSessionCount, 1))/1 sessions"
                   ),
                   Achievement(
                       title: "5 Sessions",
                       description: "Complete five study sessions",
                       icon: "flame.fill",
                       currentValue: totalSessionCount,
                       targetValue: 5,
                       progressText: "\(min(totalSessionCount, 5))/5 sessions"
                   ),
                   Achievement(
                       title: "10 Sessions",
                       description: "Complete ten study sessions",
                       icon: "bolt.fill",
                       currentValue: totalSessionCount,
                       targetValue: 10,
                       progressText: "\(min(totalSessionCount, 10))/10 sessions"
                   ),
                   Achievement(
                       title: "1 Hour",
                       description: "Study for a total of one hour",
                       icon: "clock.fill",
                       currentValue: totalStudySeconds,
                       targetValue: 3600,
                       progressText: "\(min(totalStudySeconds / 60, 60))/60 min"
                   ),
                   Achievement(
                       title: "5 Hours",
                       description: "Study for a total of five hours",
                       icon: "timer",
                       currentValue: totalStudySeconds,
                       targetValue: 18000,
                       progressText: "\(min(totalStudySeconds / 60, 300))/300 min"
                   ),
                   Achievement(
                       title: "First Goal Done",
                       description: "Complete your first learning goal",
                       icon: "checkmark.seal.fill",
                       currentValue: completedGoalsCount,
                       targetValue: 1,
                       progressText: "\(min(completedGoalsCount, 1))/1 goals"
                   )
        ]
    }
    
    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }
    
    private func sanitizeSelectedGoal() {
        guard let selectedGoalId else { return }
        
        let isStillslectable = activeGoals.contains { $0.id == selectedGoalId }
        
        if !isStillslectable {
            self.selectedGoalId = nil
        }
    }
    
    var hasSelectableGoal: Bool {
        !activeGoals.isEmpty
    }
    
    private func startPomodoroTimer() {
        pomodoroTimer?.invalidate()
        
        pomodoroTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ [weak self] _ in
            guard let self else { return }
            
            if self.pomodoroRemainingSeconds > 0 {
                self.pomodoroRemainingSeconds -= 1
            } else {
                self.pomodoroTimer?.invalidate()
                self.pomodoroTimer = nil
                self.didFinishPomodoro = true
                self.stopSession()
            }
            
        }
    }
}
