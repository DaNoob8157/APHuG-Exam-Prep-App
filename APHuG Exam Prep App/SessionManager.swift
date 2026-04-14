//
//  SessionManager.swift
//  APHuG Exam Prep App
//

import Foundation
import Combine

final class SessionManager: ObservableObject {

    // MARK: - Published state

    @Published var selectedDay: Int = 1
    @Published var tasks: [StudyTask] = []
    @Published var completedIndices: Set<Int> = []

    @Published var currentTaskIndex: Int = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false

    /// Seconds elapsed on the current task.
    @Published var timeElapsedSeconds: Int = 0
    /// Total seconds elapsed for the whole session (across all tasks).
    @Published var totalSessionSeconds: Int = 0

    private var timer: Timer?

    // MARK: - Computed

    var currentTask: StudyTask? {
        tasks.indices.contains(currentTaskIndex) ? tasks[currentTaskIndex] : nil
    }

    var timeRemainingSeconds: Int {
        guard let t = currentTask else { return 0 }
        return max(0, t.suggestedMinutes * 60 - timeElapsedSeconds)
    }

    var isOverTime: Bool {
        guard let t = currentTask else { return false }
        return timeElapsedSeconds > t.suggestedMinutes * 60
    }

    var overTimeSeconds: Int {
        guard let t = currentTask, isOverTime else { return 0 }
        return timeElapsedSeconds - t.suggestedMinutes * 60
    }

    /// 0…1 progress of the current task's countdown.
    var taskProgress: Double {
        guard let t = currentTask, t.suggestedMinutes > 0 else { return 0 }
        return min(1.0, Double(timeElapsedSeconds) / Double(t.suggestedMinutes * 60))
    }

    /// 0…1 progress of how many tasks in the day are done.
    var sessionProgress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedIndices.count) / Double(tasks.count)
    }

    var isSessionComplete: Bool { !tasks.isEmpty && completedIndices.count == tasks.count }

    /// True once the user has clocked in (even if now paused).
    var hasStarted: Bool { isRunning || isPaused || totalSessionSeconds > 0 }

    // MARK: - Day loading

    func loadDay(_ day: Int, from allTasks: [StudyTask]) {
        selectedDay = day
        tasks = StudyTask.tasks(for: day, from: allTasks)

        // Restore completion from UserDefaults
        completedIndices = Set(tasks.indices.filter {
            UserDefaults.standard.bool(forKey: tasks[$0].completionKey)
        })

        // Resume at the first incomplete task
        currentTaskIndex = tasks.indices.first { !completedIndices.contains($0) } ?? 0

        isRunning = false
        isPaused  = false
        timeElapsedSeconds  = 0
        totalSessionSeconds = 0
        stopTimer()
    }

    // MARK: - Controls

    func clockIn() {
        guard !isSessionComplete else { return }
        isRunning = true
        isPaused  = false
        startTimer()
    }

    func pause() {
        isRunning = false
        isPaused  = true
        stopTimer()
    }

    func resume() {
        guard !isSessionComplete else { return }
        isRunning = true
        isPaused  = false
        startTimer()
    }

    func completeAndNext() {
        guard tasks.indices.contains(currentTaskIndex) else { return }

        // Persist and record completion
        UserDefaults.standard.set(true, forKey: tasks[currentTaskIndex].completionKey)
        completedIndices.insert(currentTaskIndex)
        timeElapsedSeconds = 0

        if isSessionComplete {
            isRunning = false
            stopTimer()
            return
        }

        // Advance to next incomplete task
        if let next = tasks.indices.first(where: { $0 > currentTaskIndex && !completedIndices.contains($0) }) {
            currentTaskIndex = next
        } else if let next = tasks.indices.first(where: { !completedIndices.contains($0) }) {
            currentTaskIndex = next
        }
    }

    func jumpToTask(_ index: Int) {
        guard tasks.indices.contains(index) else { return }
        currentTaskIndex   = index
        timeElapsedSeconds = 0
    }

    func resetDay() {
        tasks.indices.forEach {
            UserDefaults.standard.removeObject(forKey: tasks[$0].completionKey)
        }
        completedIndices    = []
        currentTaskIndex    = 0
        timeElapsedSeconds  = 0
        totalSessionSeconds = 0
        isRunning = false
        isPaused  = false
        stopTimer()
    }

    // MARK: - Timer

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, self.isRunning else { return }
            self.timeElapsedSeconds  += 1
            self.totalSessionSeconds += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    deinit { timer?.invalidate() }
}
