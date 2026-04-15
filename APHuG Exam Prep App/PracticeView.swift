//
//  PracticeView.swift
//  APHuG Exam Prep App
//

import SwiftUI

// MARK: - Data model

struct PracticeExamSource: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let url: URL
    let icon: String
    let color: Color
    let tags: [PracticeTag]
    let attribution: String

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (l: Self, r: Self) -> Bool { l.id == r.id }
}

enum PracticeTag: String, CaseIterable {
    case official = "Official"
    case mc       = "MC"
    case frq      = "FRQ"
    case free     = "Free"
    case video    = "Video"

    var color: Color {
        switch self {
        case .official: return .blue
        case .mc:       return .orange
        case .frq:      return .purple
        case .free:     return .green
        case .video:    return .red
        }
    }
}

// MARK: - Source catalogue

let practiceExamSources: [PracticeExamSource] = [
    // Official
    PracticeExamSource(
        name: "College Board — Past FRQs",
        description: "Every released FRQ prompt and official scoring guideline since 2001.",
        url: URL(string: "https://apcentral.collegeboard.org/courses/ap-human-geography/exam/past-exam-questions")!,
        icon: "building.columns.fill", color: .blue,
        tags: [.official, .frq, .free], attribution: "apcentral.collegeboard.org"),
    PracticeExamSource(
        name: "AP Classroom",
        description: "Official progress checks and AP Daily practice with automatic scoring.",
        url: URL(string: "https://myap.collegeboard.org/")!,
        icon: "building.columns.fill", color: .blue,
        tags: [.official, .mc, .frq], attribution: "myap.collegeboard.org"),
    // MC practice
    PracticeExamSource(
        name: "Albert.io",
        description: "2,000+ questions with unit filters, timed exam modes, and detailed explanations.",
        url: URL(string: "https://www.albert.io/ap-human-geography")!,
        icon: "graduationcap.fill", color: .orange,
        tags: [.mc, .frq], attribution: "albert.io"),
    PracticeExamSource(
        name: "Knowt",
        description: "Student-made and teacher-verified practice tests and flashcard-based quizzes.",
        url: URL(string: "https://knowt.com/exams/AP/AP-Human-Geography")!,
        icon: "bolt.fill", color: .yellow,
        tags: [.mc, .free], attribution: "knowt.com"),
    PracticeExamSource(
        name: "Lumisource",
        description: "AI-powered practice questions and concept mastery checks for each unit.",
        url: URL(string: "https://lumisource.io/courses/ap-human-geography")!,
        icon: "sparkles", color: .purple,
        tags: [.mc, .frq, .free], attribution: "lumisource.io"),
    PracticeExamSource(
        name: "Save My Exams",
        description: "Concise revision notes and topic-specific practice with mark schemes.",
        url: URL(string: "https://www.savemyexams.com/ap/human-geography/")!,
        icon: "checkmark.seal.fill", color: .teal,
        tags: [.mc, .frq], attribution: "savemyexams.com"),
    PracticeExamSource(
        name: "PrepScholar",
        description: "Full-length diagnostic tests with score analysis and unit breakdowns.",
        url: URL(string: "https://www.prepscholar.com/act/s/ap-human-geography")!,
        icon: "chart.bar.fill", color: .indigo,
        tags: [.mc, .free], attribution: "prepscholar.com"),
    // FRQ focused
    PracticeExamSource(
        name: "Fiveable — FRQ Walkthroughs",
        description: "Live and recorded FRQ practice with expert step-by-step breakdowns.",
        url: URL(string: "https://library.fiveable.me/ap-hug")!,
        icon: "text.bubble.fill", color: .pink,
        tags: [.frq, .free], attribution: "library.fiveable.me"),
    // Video
    PracticeExamSource(
        name: "Heimler's History",
        description: "Unit review videos and exam-technique tips from a veteran AP teacher.",
        url: URL(string: "https://www.youtube.com/playlist?list=PLiswPBuJdN-d-1hzA_nJv4_QF-JNIhxNQ")!,
        icon: "play.rectangle.fill", color: .red,
        tags: [.video, .free], attribution: "youtube.com"),
    PracticeExamSource(
        name: "Khan Academy",
        description: "Free lessons, unit reviews, and adaptive practice exercises.",
        url: URL(string: "https://www.khanacademy.org/humanities/ap-human-geography")!,
        icon: "leaf.fill", color: .green,
        tags: [.mc, .video, .free], attribution: "khanacademy.org"),
]

// MARK: - Main view

struct PracticeView: View {
    @Binding var selectedSource: PracticeExamSource?
    @ObservedObject var navigator: WebViewNavigator
    @State private var selectedTag: PracticeTag? = nil

    var filteredSources: [PracticeExamSource] {
        guard let tag = selectedTag else { return practiceExamSources }
        return practiceExamSources.filter { $0.tags.contains(tag) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tag filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    PracticeFilterChip(label: "All", color: .secondary, isSelected: selectedTag == nil) {
                        selectedTag = nil
                    }
                    ForEach(PracticeTag.allCases, id: \.self) { tag in
                        PracticeFilterChip(label: tag.rawValue, color: tag.color, isSelected: selectedTag == tag) {
                            selectedTag = selectedTag == tag ? nil : tag
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            Divider()

            // Source list
            List(filteredSources, selection: $selectedSource) { source in
                PracticeSourceRow(source: source)
                    .tag(source)
                    .contentShape(Rectangle())
            }
            .listStyle(.sidebar)
            .background(.thinMaterial)
            .onChange(of: selectedSource) { _, newVal in
                if let src = newVal { navigator.load(src.url) }
            }
        }
    }
}

// MARK: - Welcome grid (shown in detail pane when nothing selected)

struct PracticeWelcomeView: View {
    let onSelect: (PracticeExamSource) -> Void
    private let columns = [GridItem(.adaptive(minimum: 170))]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Practice Exams")
                        .font(.largeTitle.bold())
                    Text("Pick a resource to open it here, or tap ↗ to open in Chrome.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(practiceExamSources) { src in
                        PracticeSourceCard(source: src) { onSelect(src) }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Supporting views

struct PracticeFilterChip: View {
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isSelected ? color : Color.secondary.opacity(0.12))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct PracticeSourceRow: View {
    let source: PracticeExamSource

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: source.icon)
                    .foregroundStyle(source.color)
                Text(source.name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
            }
            Text(source.attribution)
                .font(.caption2)
                .foregroundStyle(.secondary)
            HStack(spacing: 4) {
                ForEach(source.tags, id: \.self) { tag in
                    Text(tag.rawValue)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(tag.color.opacity(0.15))
                        .foregroundStyle(tag.color)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 2)
    }
}

struct PracticeSourceCard: View {
    let source: PracticeExamSource
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: source.icon)
                        .foregroundStyle(.white)
                        .font(.title3)
                        .frame(width: 36, height: 36)
                        .background(source.color.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Spacer()
                    Button { openInChrome(source.url) } label: {
                        Image(systemName: "arrow.up.right.square").foregroundStyle(.secondary)
                    }.buttonStyle(.plain)
                }
                Text(source.name)
                    .font(.body.weight(.semibold)).lineLimit(2).foregroundStyle(.primary)
                Text(source.description)
                    .font(.caption).foregroundStyle(.secondary).lineLimit(3)
                HStack(spacing: 4) {
                    ForEach(source.tags, id: \.self) { tag in
                        Text(tag.rawValue)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(tag.color.opacity(0.15))
                            .foregroundStyle(tag.color)
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
                Text(source.attribution).font(.caption2).foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(hovered ? Color.accentColor.opacity(0.06) : Color(.windowBackgroundColor))
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(hovered ? Color.accentColor.opacity(0.3) : Color.secondary.opacity(0.15), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}
