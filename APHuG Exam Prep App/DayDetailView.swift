//
//  DayDetailView.swift
//  APHuG Exam Prep App
//
//  Created by apmckelvey on 4/14/26.
//

import SwiftUI

struct DayDetailView: View {
    let day: StudyDay
    @State private var completed: Bool
    var onToggleComplete: (Bool) -> Void

    init(day: StudyDay, onToggleComplete: @escaping (Bool) -> Void) {
        self.day = day
        self._completed = State(initialValue: day.isCompleted)
        self.onToggleComplete = onToggleComplete
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Day \(day.day)")
                            .font(.largeTitle.bold())
                        Text(day.unitFocus)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        completed.toggle()
                        var mutableDay = day
                        mutableDay.isCompleted = completed
                        onToggleComplete(completed)
                    } label: {
                        Label(
                            completed ? "Completed" : "Mark Complete",
                            systemImage: completed ? "checkmark.circle.fill" : "circle"
                        )
                        .font(.body.weight(.medium))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(completed ? .green : .blue)
                }
                .padding(.bottom, 4)

                Divider()

                // Content Focus
                TaskCard(
                    icon: "book.fill",
                    title: "Content Focus",
                    subtitle: "≈ 30 minutes",
                    color: .blue,
                    content: day.contentFocus
                )

                // Practice MC
                TaskCard(
                    icon: "list.bullet.rectangle.fill",
                    title: "Practice Multiple Choice",
                    subtitle: "≈ 20 minutes",
                    color: .orange,
                    content: day.practiceMC
                )

                // FRQ Work
                TaskCard(
                    icon: "pencil.and.outline",
                    title: "FRQ Work",
                    subtitle: "≈ 10 minutes",
                    color: .purple,
                    content: day.frqWork
                )

                // Total time reminder
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.secondary)
                    Text("Total estimated time: ~60 minutes")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                // Unit-specific resource links
                let unitResources = StudyResource.unitResources(for: day.unitFocus)
                if !unitResources.isEmpty {
                    Divider()
                        .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 10) {
                        Label("Resources for \(day.unitFocus)", systemImage: "link")
                            .font(.headline)

                        ForEach(unitResources) { resource in
                            Link(destination: resource.url) {
                                HStack(spacing: 10) {
                                    Image(systemName: "arrow.up.right.square.fill")
                                        .foregroundStyle(.blue)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(resource.title)
                                            .font(.body.weight(.medium))
                                            .foregroundStyle(.primary)
                                        Text(resource.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }
                                    Spacer()
                                }
                                .padding(10)
                                .background(Color.blue.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}

struct TaskCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Text(content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
