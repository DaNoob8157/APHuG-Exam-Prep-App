//
//  SessionView.swift
//  APHuG Exam Prep App
//

import SwiftUI

// MARK: - Content pane: day picker + task list

struct SessionView: View {
    @ObservedObject var manager: SessionManager
    let allTasks: [StudyTask]

    private var availableDays: [Int] { StudyTask.availableDays(from: allTasks) }

    private var remainingMinutes: Int {
        manager.tasks.enumerated()
            .filter { !manager.completedIndices.contains($0.offset) }
            .reduce(0) { $0 + $1.element.suggestedMinutes }
    }

    var body: some View {
        VStack(spacing: 0) {

            // Day picker header
            VStack(spacing: 10) {
                HStack {
                    Button {
                        if let prev = availableDays.last(where: { $0 < manager.selectedDay }) {
                            manager.loadDay(prev, from: allTasks)
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.plain)
                    .disabled(manager.selectedDay <= (availableDays.first ?? 1))

                    Spacer()

                    VStack(spacing: 2) {
                        Text("Day \(manager.selectedDay)")
                            .font(.headline)
                        if let first = manager.tasks.first {
                            Text(first.unitFocus)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Button {
                        if let next = availableDays.first(where: { $0 > manager.selectedDay }) {
                            manager.loadDay(next, from: allTasks)
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.plain)
                    .disabled(manager.selectedDay >= (availableDays.last ?? 14))
                }

                // Progress bar
                VStack(spacing: 4) {
                    ProgressView(value: manager.sessionProgress)
                        .tint(manager.isSessionComplete ? .green : .blue)
                    HStack {
                        Text("\(manager.completedIndices.count) of \(manager.tasks.count) tasks")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if manager.isSessionComplete {
                            Label("All done!", systemImage: "checkmark.seal.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                        } else {
                            Text("~\(remainingMinutes) min left")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            // Task list — clicking a row jumps to that task
            List(selection: Binding<Int?>(
                get: { manager.hasStarted ? manager.currentTaskIndex : nil },
                set: { if let i = $0 { manager.jumpToTask(i) } }
            )) {
                ForEach(Array(manager.tasks.enumerated()), id: \.element.id) { index, task in
                    SessionTaskRow(
                        task: task,
                        index: index,
                        isCurrent: index == manager.currentTaskIndex && manager.hasStarted,
                        isCompleted: manager.completedIndices.contains(index)
                    )
                    .tag(index)
                    .contentShape(Rectangle())
                }
            }
            .listStyle(.sidebar)
        }
        .onAppear {
            if manager.tasks.isEmpty, let first = availableDays.first {
                manager.loadDay(first, from: allTasks)
            }
        }
    }
}

// MARK: - Task row

struct SessionTaskRow: View {
    let task: StudyTask
    let index: Int
    let isCurrent: Bool
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 10) {
            // Status badge
            ZStack {
                Circle()
                    .fill(rowColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: statusIcon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(rowColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(task.taskType.shortName)
                        .font(.body.weight(isCurrent ? .semibold : .regular))
                        .foregroundStyle(isCurrent ? task.taskType.color : .primary)
                    Spacer()
                    Text("\(task.suggestedMinutes) min")
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(task.taskType.color.opacity(0.12))
                        .foregroundStyle(task.taskType.color)
                        .clipShape(Capsule())
                }
                Text(task.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 3)
        .opacity(isCompleted && !isCurrent ? 0.45 : 1)
    }

    private var statusIcon: String {
        if isCompleted   { return "checkmark" }
        if isCurrent     { return task.taskType.isBreak ? "cup.and.saucer.fill" : "play.fill" }
        return task.taskType.isBreak ? "cup.and.saucer" : "circle"
    }

    private var rowColor: Color {
        if isCompleted { return .green }
        if isCurrent   { return task.taskType.color }
        return .secondary
    }
}
