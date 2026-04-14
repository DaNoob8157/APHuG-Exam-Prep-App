//
//  CustomStudyDay.swift
//  APHuG Exam Prep App
//
//  Codable model for user-created study days, persisted in UserDefaults as JSON.
//

import Foundation

// MARK: - Model

struct CustomStudyDay: Identifiable, Codable {
    var id: UUID
    var title: String
    var unitFocus: String
    var tasks: [CustomTask]
    var notes: String
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String = "",
        unitFocus: String = "Unit 1",
        tasks: [CustomTask] = [],
        notes: String = "",
        isCompleted: Bool = false
    ) {
        self.id         = id
        self.title      = title
        self.unitFocus  = unitFocus
        self.tasks      = tasks
        self.notes      = notes
        self.isCompleted = isCompleted
    }

    /// Total planned minutes across all tasks.
    var totalMinutes: Int { tasks.reduce(0) { $0 + $1.durationMinutes } }
}

struct CustomTask: Identifiable, Codable {
    var id: UUID
    var type: CustomTaskType
    var durationMinutes: Int
    var description: String

    init(
        id: UUID = UUID(),
        type: CustomTaskType = .study,
        durationMinutes: Int = 15,
        description: String = ""
    ) {
        self.id              = id
        self.type            = type
        self.durationMinutes = durationMinutes
        self.description     = description
    }
}

enum CustomTaskType: String, Codable, CaseIterable {
    case study   = "Study"
    case practice = "Practice MC"
    case frq     = "FRQ Work"
    case review  = "Review"
    case breakTime = "Break"
    case other   = "Other"

    var icon: String {
        switch self {
        case .study:     return "book.fill"
        case .practice:  return "list.bullet.rectangle.fill"
        case .frq:       return "pencil.and.outline"
        case .review:    return "arrow.clockwise"
        case .breakTime: return "cup.and.saucer.fill"
        case .other:     return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Persistence

extension CustomStudyDay {
    private static let defaultsKey = "custom_study_days_v1"

    static func load() -> [CustomStudyDay] {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let days  = try? JSONDecoder().decode([CustomStudyDay].self, from: data) else {
            return []
        }
        return days
    }

    static func save(_ days: [CustomStudyDay]) {
        guard let data = try? JSONEncoder().encode(days) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }
}
