//
//  StudyTask.swift
//  APHuG Exam Prep App
//

import Foundation
import SwiftUI

// MARK: - Model

struct StudyTask: Identifiable {
    let id: UUID
    /// Calendar day number (1–14).
    let day: Int
    /// 0-based position within that day's task list — used for stable UserDefaults keys.
    let taskIndex: Int
    let unitFocus: String
    let taskType: TaskType
    /// Upper-bound minutes parsed from the "Suggested time" column.
    let suggestedMinutes: Int
    let description: String

    /// Stable key used to persist completion across launches.
    var completionKey: String { "task_d\(day)_i\(taskIndex)" }

    // MARK: Task Type

    enum TaskType: String, CaseIterable {
        case spacedReview       = "Spaced review"
        case newContent         = "New content + active recall"
        case activeRecall       = "Active recall (big picture)"
        case activeRecallPolish = "Active recall polish"
        case breakTime          = "Break"
        case mcqPractice        = "MCQ practice"
        case mcqMixed           = "MCQ practice (mixed)"
        case frqMicro           = "FRQ micro"
        case frqPractice        = "FRQ practice"

        static func from(_ raw: String) -> TaskType {
            TaskType(rawValue: raw) ?? .newContent
        }

        var isBreak: Bool { self == .breakTime }

        var shortName: String {
            switch self {
            case .spacedReview:                       return "Spaced Review"
            case .newContent:                         return "New Content"
            case .activeRecall, .activeRecallPolish:  return "Active Recall"
            case .breakTime:                          return "Break"
            case .mcqPractice, .mcqMixed:             return "MCQ Practice"
            case .frqMicro, .frqPractice:             return "FRQ Work"
            }
        }

        var icon: String {
            switch self {
            case .spacedReview:                       return "arrow.clockwise"
            case .newContent:                         return "book.fill"
            case .activeRecall, .activeRecallPolish:  return "brain.head.profile"
            case .breakTime:                          return "cup.and.saucer.fill"
            case .mcqPractice, .mcqMixed:             return "list.bullet.rectangle.fill"
            case .frqMicro, .frqPractice:             return "pencil.and.outline"
            }
        }

        var color: Color {
            switch self {
            case .spacedReview:                       return .blue
            case .newContent:                         return .indigo
            case .activeRecall, .activeRecallPolish:  return .purple
            case .breakTime:                          return .green
            case .mcqPractice, .mcqMixed:             return .orange
            case .frqMicro, .frqPractice:             return .pink
            }
        }
    }
}

// MARK: - CSV Loading

extension StudyTask {

    /// Loads all tasks from the bundled `DetailedStudyPlan.csv`.
    static func loadAll() -> [StudyTask] {
        guard let url = Bundle.main.url(forResource: "DetailedStudyPlan", withExtension: "csv"),
              let contents = try? String(contentsOf: url, encoding: .utf8) else {
            return embeddedFallback
        }

        var tasks: [StudyTask] = []
        var dayTaskCounts: [Int: Int] = [:]

        let lines = contents.components(separatedBy: .newlines).filter { !$0.isEmpty }
        for line in lines.dropFirst() {          // skip header
            let fields = parseCSVLine(line)
            guard fields.count >= 5 else { continue }

            let day      = Int(fields[0].trimmingCharacters(in: .whitespaces)) ?? 1
            let idx      = dayTaskCounts[day, default: 0]
            dayTaskCounts[day] = idx + 1

            tasks.append(StudyTask(
                id:               UUID(),
                day:              day,
                taskIndex:        idx,
                unitFocus:        fields[1].trimmingCharacters(in: .whitespaces),
                taskType:         TaskType.from(fields[2].trimmingCharacters(in: .whitespaces)),
                suggestedMinutes: parseMinutes(fields[3].trimmingCharacters(in: .whitespaces)),
                description:      fields[4].trimmingCharacters(in: .whitespaces)
            ))
        }

        return tasks.isEmpty ? embeddedFallback : tasks
    }

    /// Returns the ordered tasks for one study day.
    static func tasks(for day: Int, from all: [StudyTask]) -> [StudyTask] {
        all.filter { $0.day == day }.sorted { $0.taskIndex < $1.taskIndex }
    }

    /// All unique day numbers present in the task list.
    static func availableDays(from all: [StudyTask]) -> [Int] {
        Array(Set(all.map { $0.day })).sorted()
    }

    // MARK: - Parsing helpers

    /// Parses "5 min", "25 min", "5–10 min" → upper bound in whole minutes.
    static func parseMinutes(_ raw: String) -> Int {
        let clean = raw
            .replacingOccurrences(of: "min", with: "")
            .replacingOccurrences(of: " ", with: "")
        for sep in ["–", "-", "—"] where clean.contains(sep) {
            if let val = Int(clean.components(separatedBy: sep).last ?? "") { return val }
        }
        return Int(clean) ?? 10
    }

    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                fields.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        fields.append(current)
        return fields
    }

    // MARK: - Embedded fallback (Day 1 only, used if CSV is missing)

    static let embeddedFallback: [StudyTask] = [
        StudyTask(id: UUID(), day: 1, taskIndex: 0, unitFocus: "Unit 7",
                  taskType: .spacedReview, suggestedMinutes: 5,
                  description: "Quick pass of any existing HuG cards."),
        StudyTask(id: UUID(), day: 1, taskIndex: 1, unitFocus: "Unit 7",
                  taskType: .newContent, suggestedMinutes: 25,
                  description: "Sectors, HDI/GNI, indicators, Rostow, core–periphery; make cards + small concept map."),
        StudyTask(id: UUID(), day: 1, taskIndex: 2, unitFocus: "Unit 7",
                  taskType: .breakTime, suggestedMinutes: 5,
                  description: "Stand up, water, no phone scrolling."),
        StudyTask(id: UUID(), day: 1, taskIndex: 3, unitFocus: "Unit 7",
                  taskType: .mcqPractice, suggestedMinutes: 15,
                  description: "10–15 Unit 7 questions, mark misses."),
        StudyTask(id: UUID(), day: 1, taskIndex: 4, unitFocus: "Unit 7",
                  taskType: .frqMicro, suggestedMinutes: 10,
                  description: "Short HDI explanation + 1 limitation."),
    ]
}
