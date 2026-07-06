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
    @Published var currendGoalTitle: String = ""

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
            currendGoalTitle = goal.title
        }
    }
    
    func stopSession(){
        guard let selectedGoalId,
              let goal = goals.first(where: { $0.id == selectedGoalId }),
              let start = activeSessionStart else { return }
        
        let end = Date()
        let duration = Int(end.timeIntervalSince(start))
        
        let session = StudySession( id: UUID(), goalId: goal.id, goalTitle: goal.title, startedAt: start, endedAt: end, duarationInSeconds: duration)
        sessions.insert(session, at: 0)
        activeSessionStart = nil
        currendGoalTitle = ""
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
