//
//  StudyPlanView.swift
//  APHuG Exam Prep App
//
//  Created by apmckelvey on 4/14/26.
//

import SwiftUI

struct StudyPlanView: View {
    @Binding var studyDays: [StudyDay]
    @Binding var selectedDay: StudyDay?

    var completedCount: Int {
        studyDays.filter { $0.isCompleted }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress header
            VStack(spacing: 8) {
                Text("14-Day AP Human Geography Study Plan")
                    .font(.headline)
                ProgressView(value: Double(completedCount), total: Double(studyDays.count))
                    .tint(.green)
                Text("\(completedCount) of \(studyDays.count) days completed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.thinMaterial)

            Divider()

            // Day list
            List(studyDays, selection: $selectedDay) { day in
                StudyDayRow(day: day)
                    .tag(day)
                    .contentShape(Rectangle())
            }
            .background(.thinMaterial)
        }
    }
}

struct StudyDayRow: View {
    let day: StudyDay

    var body: some View {
        HStack(spacing: 12) {
            // Day number badge
            ZStack {
                Circle()
                    .fill(day.isCompleted ? Color.green : unitColor(for: day.unitFocus))
                    .frame(width: 36, height: 36)
                if day.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(day.day)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Day \(day.day) — \(day.unitFocus)")
                    .font(.body.weight(.medium))
                Text(day.contentFocus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    func unitColor(for unit: String) -> Color {
        switch unit {
        case "Unit 1": return .blue
        case "Unit 2": return .orange
        case "Unit 3": return .purple
        case "Unit 4": return .red
        case "Unit 5": return .brown
        case "Unit 6": return .teal
        case "Unit 7": return .indigo
        default: return .gray
        }
    }
}

extension StudyDay: Hashable {
    static func == (lhs: StudyDay, rhs: StudyDay) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
