import Foundation
import Combine
import SwiftUI

final class AppViewModel: ObservableObject {
    @Published var goals: [LearningGoal] = []
    @Published var title: String = ""
    @Published var subject: String = ""
    @Published var canSave: Bool = false
    @Published var sessions: [StudySession] = []
    @Published var selectedGoalId: UUID?
    @Published var activeSessionStart: Date?
    @Published var currentdGoalTitle: String = ""

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
        $goals.sink{ [weak self] goals in
            self?.storage.save(goals)
        }
        .store(in: &cancellables)
        
        $sessions.sink { [weak self] sessions in
            self?.storage.saveSession(sessions)
        }.store(in: &cancellables)
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
    
    func startSession(){
        guard let selectedGoalId,
              let goal = goals.first(where: { $0.id == selectedGoalId }) else { return }
        if activeSessionStart == nil {
            activeSessionStart = Date()
            currentdGoalTitle = goal.title
        }
    }
    
    func stopSession(){
        guard let selectedGoalId,
              let goal = goals.first(where: { $0.id == selectedGoalId }),
              let start = activeSessionStart else { return }
        
        let end = Date()
        let duration = Int(end.timeIntervalSince(start))
        
        let session = StudySession( id: UUID(), goalId: goal.id, goalTitle: goal.title, startedAt: start, endedAt: end, durationInSeconds: duration)
        sessions.insert(session, at: 0)
        activeSessionStart = nil
        currentdGoalTitle = ""
    }
    
    func updateGoal(id: UUID, title: String, subject: String){
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSubject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty, !trimmedSubject.isEmpty else { return }
        
        guard let index = goals.firstIndex(where: { $0.id == id }) else { return }
        goals[index].title = trimmedTitle
        goals[index].subject = trimmedSubject
    }
}



extension AppViewModel{
    
    var totalGoalCount: Int {
        goals.count
    }
    
    var activeGoalCount: Int {
        goals.filter { !$0.isCompleted }.count
    }
    var totalSessionCount: Int {
        sessions.count
    }
    var totalStudySeconds: Int {
        sessions.reduce (0){$0 + $1.durationInSeconds}
    }
    
    var totalStudyTimeText: String{
        let minutes = totalStudySeconds / 60
        let seconds = totalStudySeconds % 60
        
        let hour = minutes / 60
        let minute = minutes % 60
        
        if hour > 0 {
            return "\(hour)h \(minute)m \(seconds)s"
        }else if minutes > 0{
            return "\(minute)m \(seconds)s"
        }else {
            return "\(seconds)s"
        }
    }
    
    var completedGoalsCount: Int {
        goals.filter { $0.isCompleted }.count
    }
    
    var recentGoals: [LearningGoal]{
        Array(goals.prefix(3))
    }
    
    
    
}
