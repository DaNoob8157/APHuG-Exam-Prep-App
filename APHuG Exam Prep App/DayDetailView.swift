//
//  DayDetailView.swift
//  APHuG Exam Prep App
//
//  Created by apmckelvey on 4/14/26.
//

import SwiftUI

// MARK: - Per-task study links

private struct TaskLink {
    let label: String
    let url: URL
}

/// Returns direct "study now" links for the content-focus task (reading/review).
private func contentLinks(for unitFocus: String) -> [TaskLink] {
    var links: [TaskLink] = [
        TaskLink(label: "AP Daily Videos (AP Classroom)", url: URL(string: "https://myap.collegeboard.org/")!),
        TaskLink(label: "Heimler's History — Unit Playlist", url: URL(string: "https://www.youtube.com/playlist?list=PLiswPBuJdN-d-1hzA_nJv4_QF-JNIhxNQ")!)
    ]
    // Unit-specific supplemental
    switch unitFocus {
    case "Unit 1":
        links.append(TaskLink(label: "Lumisource — Unit 1 Guide", url: URL(string: "https://lumisource.io/courses/ap-human-geography")!))
        links.append(TaskLink(label: "Fiveable — Unit 1 Study Guide", url: URL(string: "https://library.fiveable.me/ap-hug/unit-1")!))
    case "Unit 2":
        links.append(TaskLink(label: "Population Reference Bureau", url: URL(string: "https://www.prb.org/")!))
        links.append(TaskLink(label: "Fiveable — Unit 2 Study Guide", url: URL(string: "https://library.fiveable.me/ap-hug/unit-2")!))
    case "Unit 3":
        links.append(TaskLink(label: "Fiveable — Unit 3 Study Guide", url: URL(string: "https://library.fiveable.me/ap-hug/unit-3")!))
        links.append(TaskLink(label: "Knowt — Culture Flashcards", url: URL(string: "https://knowt.com/exams/AP/AP-Human-Geography")!))
    case "Unit 4":
        links.append(TaskLink(label: "CIA World Factbook", url: URL(string: "https://www.cia.gov/the-world-factbook/")!))
        links.append(TaskLink(label: "Fiveable — Unit 4 Study Guide", url: URL(string: "https://library.fiveable.me/ap-hug/unit-4")!))
    case "Unit 5":
        links.append(TaskLink(label: "USDA Economic Research Service", url: URL(string: "https://www.ers.usda.gov/")!))
        links.append(TaskLink(label: "Fiveable — Unit 5 Study Guide", url: URL(string: "https://library.fiveable.me/ap-hug/unit-5")!))
    case "Unit 6":
        links.append(TaskLink(label: "Fiveable — Unit 6 Study Guide", url: URL(string: "https://library.fiveable.me/ap-hug/unit-6")!))
        links.append(TaskLink(label: "Knowt — Urban Flashcards", url: URL(string: "https://knowt.com/exams/AP/AP-Human-Geography")!))
    case "Unit 7":
        links.append(TaskLink(label: "World Bank Open Data", url: URL(string: "https://data.worldbank.org/")!))
        links.append(TaskLink(label: "UNDP Human Development Reports", url: URL(string: "https://hdr.undp.org/")!))
        links.append(TaskLink(label: "Fiveable — Unit 7 Study Guide", url: URL(string: "https://library.fiveable.me/ap-hug/unit-7")!))
    default: break
    }
    return links
}

/// Returns direct "practice now" links for the MC task.
private func mcLinks(for unitFocus: String) -> [TaskLink] {
    let albertBase = "https://www.albert.io/ap-human-geography"
    let unitSlug: String
    switch unitFocus {
    case "Unit 1": unitSlug = "/unit-1"
    case "Unit 2": unitSlug = "/unit-2"
    case "Unit 3": unitSlug = "/unit-3"
    case "Unit 4": unitSlug = "/unit-4"
    case "Unit 5": unitSlug = "/unit-5"
    case "Unit 6": unitSlug = "/unit-6"
    case "Unit 7": unitSlug = "/unit-7"
    default: unitSlug = ""
    }
    return [
        TaskLink(label: "Albert.io — MC Practice", url: URL(string: albertBase + unitSlug)!),
        TaskLink(label: "Save My Exams — Practice Questions", url: URL(string: "https://www.savemyexams.com/ap/human-geography/")!),
        TaskLink(label: "Knowt — Flashcards & Practice Tests", url: URL(string: "https://knowt.com/exams/AP/AP-Human-Geography")!),
        TaskLink(label: "PrepScholar — Practice Tests", url: URL(string: "https://www.prepscholar.com/act/s/ap-human-geography")!)
    ]
}

/// Returns direct links for the FRQ writing task.
private let frqLinks: [TaskLink] = [
    TaskLink(label: "College Board — Past FRQ Prompts & Rubrics", url: URL(string: "https://apcentral.collegeboard.org/courses/ap-human-geography/exam/past-exam-questions")!),
    TaskLink(label: "AP Classroom — FRQ Practice", url: URL(string: "https://myap.collegeboard.org/")!),
    TaskLink(label: "Fiveable — FRQ Guides", url: URL(string: "https://library.fiveable.me/ap-hug")!),
    TaskLink(label: "Lumisource — FRQ Tips", url: URL(string: "https://lumisource.io/courses/ap-human-geography")!)
]

// MARK: - Main View

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

                // Header — unit and day, completion is secondary
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Day \(day.day)")
                            .font(.largeTitle.bold())
                        Text(day.unitFocus)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                            Text("~60 min total · 30 content · 20 MC · 10 FRQ")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                    }
                    Spacer()
                }
                .padding(.bottom, 2)

                Divider()

                // Content Focus card
                PrepTaskCard(
                    icon: "book.open.fill",
                    title: "Today's Topics",
                    subtitle: "≈ 30 min — Read, watch, and review",
                    color: .blue,
                    content: day.contentFocus,
                    links: contentLinks(for: day.unitFocus)
                )

                // Practice MC card
                PrepTaskCard(
                    icon: "list.bullet.rectangle.fill",
                    title: "Practice Multiple Choice",
                    subtitle: "≈ 20 min — Drill until it sticks",
                    color: .orange,
                    content: day.practiceMC,
                    links: mcLinks(for: day.unitFocus)
                )

                // FRQ card
                PrepTaskCard(
                    icon: "pencil.and.outline",
                    title: "Free-Response Writing",
                    subtitle: "≈ 10 min — Structure matters",
                    color: .purple,
                    content: day.frqWork,
                    links: frqLinks
                )

                // Completion toggle — subtle, at the bottom
                Divider()
                    .padding(.top, 4)

                HStack {
                    Spacer()
                    Button {
                        completed.toggle()
                        var mutableDay = day
                        mutableDay.isCompleted = completed
                        onToggleComplete(completed)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                            Text(completed ? "Day complete" : "Mark as done")
                        }
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(completed ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
        }
    }
}

// MARK: - PrepTaskCard

struct PrepTaskCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let content: String
    let links: [TaskLink]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Card header
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Content description
            Text(content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            // "Study Now" links
            if !links.isEmpty {
                Divider()
                    .opacity(0.5)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(links, id: \.label) { link in
                        Link(destination: link.url) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.right.square.fill")
                                    .foregroundStyle(color)
                                    .font(.caption)
                                Text(link.label)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(color)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Keep TaskCard around for compatibility (used nowhere else, but avoids breaking builds)
struct TaskCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let content: String

    var body: some View {
        PrepTaskCard(icon: icon, title: title, subtitle: subtitle, color: color, content: content, links: [])
    }
}

