//
//  CramView.swift
//  APHuG Exam Prep App
//
//  Day-of-test cram mode: diagnostic placement quiz → targeted flashcard review → exam-day guide.
//

import SwiftUI

// MARK: - Data models

struct PlacementQuestion: Identifiable {
    let id: Int
    let unit: String
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

struct CramCard: Identifiable {
    let id = UUID()
    let unit: String
    let term: String
    let definition: String
}

private enum CramTab { case quiz, review, guide }

// MARK: - Main view

struct CramView: View {
    @State private var tab: CramTab = .quiz
    @State private var weakUnits: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            Picker("", selection: $tab) {
                Text("🎯 Diagnostic Quiz").tag(CramTab.quiz)
                Text("🃏 Rapid Review").tag(CramTab.review)
                Text("📋 Exam-Day Guide").tag(CramTab.guide)
            }
            .pickerStyle(.segmented)
            .padding(12)
            .background(.thinMaterial)

            Divider()

            switch tab {
            case .quiz:
                DiagnosticQuizView(onComplete: { units in
                    weakUnits = units
                    tab = .review
                })
            case .review:
                RapidReviewView(weakUnits: weakUnits)
            case .guide:
                ExamDayGuideView()
            }
        }
    }
}

// MARK: - Diagnostic quiz

struct DiagnosticQuizView: View {
    let onComplete: ([String]) -> Void

    @State private var state: QuizState = .ready
    @State private var questionIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var answers: [Int: Int] = [:]    // questionID → chosen index

    enum QuizState { case ready, inProgress, complete }

    private var question: PlacementQuestion { placementQuestions[questionIndex] }
    private var isLast: Bool { questionIndex == placementQuestions.count - 1 }

    var body: some View {
        switch state {
        case .ready:   quizReadyView
        case .inProgress: quizQuestionView
        case .complete:   quizResultsView
        }
    }

    // Ready screen
    private var quizReadyView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "target").font(.system(size: 64)).foregroundStyle(.blue)
            VStack(spacing: 8) {
                Text("Placement Diagnostic").font(.largeTitle.bold())
                Text("21 questions · 3 per unit · ~10 minutes")
                    .font(.title3).foregroundStyle(.secondary)
                Text("Find your weak spots before the exam so you can review what matters most.")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 40)
            }
            Button { state = .inProgress } label: {
                Label("Start Quiz", systemImage: "play.fill")
                    .font(.title3.weight(.semibold)).padding(.horizontal, 36).padding(.vertical, 13)
            }
            .buttonStyle(.borderedProminent).keyboardShortcut(.return)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // Question screen
    private var quizQuestionView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Progress
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Question \(questionIndex + 1) of \(placementQuestions.count)")
                            .font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Text(question.unit)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(unitColor(question.unit).opacity(0.15))
                            .foregroundStyle(unitColor(question.unit))
                            .clipShape(Capsule())
                    }
                    ProgressView(value: Double(questionIndex) / Double(placementQuestions.count))
                        .tint(unitColor(question.unit))
                }

                // Question
                Text(question.question)
                    .font(.title3.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)

                // Answer options
                VStack(spacing: 8) {
                    ForEach(question.options.indices, id: \.self) { i in
                        AnswerButton(
                            letter: ["A","B","C","D"][i],
                            text: question.options[i],
                            state: buttonState(for: i)
                        ) {
                            guard selectedAnswer == nil else { return }
                            selectedAnswer = i
                            answers[question.id] = i
                        }
                    }
                }

                // Explanation (shown after answering)
                if let chosen = selectedAnswer {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: chosen == question.correctIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(chosen == question.correctIndex ? .green : .red)
                            Text(chosen == question.correctIndex ? "Correct!" : "Incorrect")
                                .font(.subheadline.weight(.semibold))
                        }
                        Text(question.explanation)
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Navigation
                if selectedAnswer != nil {
                    HStack {
                        Spacer()
                        Button(isLast ? "See Results →" : "Next Question →") {
                            if isLast {
                                state = .complete
                            } else {
                                questionIndex += 1
                                selectedAnswer = nil
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.return)
                    }
                }
            }
            .padding(24)
        }
    }

    // Results screen
    private var quizResultsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your Results").font(.largeTitle.bold()).padding(.top, 4)

                let scores = unitScores()
                ForEach(["Unit 1","Unit 2","Unit 3","Unit 4","Unit 5","Unit 6","Unit 7"], id: \.self) { unit in
                    if let (correct, total) = scores[unit] {
                        UnitScoreCard(unit: unit, correct: correct, total: total)
                    }
                }

                let weak = scores.filter { $0.value.correct < 2 }.map { $0.key }.sorted()
                if !weak.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Needs Review").font(.headline)
                        Text(weak.joined(separator: ", "))
                            .font(.subheadline).foregroundStyle(.orange)
                        Button("Review Weak Units →") { onComplete(weak) }
                            .buttonStyle(.borderedProminent).tint(.orange)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Great job — no major weak spots!").font(.headline).foregroundStyle(.green)
                        Button("Review All Units →") { onComplete([]) }
                            .buttonStyle(.bordered)
                    }
                }

                Button { questionIndex = 0; selectedAnswer = nil; answers = [:]; state = .ready } label: {
                    Label("Retake Quiz", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }
            .padding(24)
        }
    }

    private func buttonState(for i: Int) -> AnswerButtonState {
        guard let chosen = selectedAnswer else { return .idle }
        if i == question.correctIndex { return .correct }
        if i == chosen { return .wrong }
        return .dimmed
    }

    private func unitScores() -> [String: (correct: Int, total: Int)] {
        var scores: [String: (correct: Int, total: Int)] = [:]
        for q in placementQuestions {
            let prev = scores[q.unit] ?? (0, 0)
            let correct = answers[q.id] == q.correctIndex ? 1 : 0
            scores[q.unit] = (prev.correct + correct, prev.total + 1)
        }
        return scores
    }

    private func unitColor(_ unit: String) -> Color {
        switch unit {
        case "Unit 1": return .blue;  case "Unit 2": return .orange
        case "Unit 3": return .purple; case "Unit 4": return .red
        case "Unit 5": return .brown;  case "Unit 6": return .teal
        case "Unit 7": return .indigo; default: return .gray
        }
    }
}

// MARK: - Answer button

enum AnswerButtonState { case idle, correct, wrong, dimmed }

struct AnswerButton: View {
    let letter: String
    let text: String
    let state: AnswerButtonState
    let action: () -> Void

    private var bg: Color {
        switch state {
        case .idle: return Color.secondary.opacity(0.08)
        case .correct: return .green.opacity(0.18)
        case .wrong: return .red.opacity(0.18)
        case .dimmed: return Color.secondary.opacity(0.04)
        }
    }
    private var border: Color {
        switch state {
        case .correct: return .green; case .wrong: return .red
        default: return .clear
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(letter)
                    .font(.body.weight(.bold)).frame(width: 28, height: 28)
                    .background(border == .clear ? Color.secondary.opacity(0.15) : border.opacity(0.25))
                    .clipShape(Circle())
                Text(text)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(12)
            .background(bg)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(border, lineWidth: 1.5))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .opacity(state == .dimmed ? 0.5 : 1)
    }
}

// MARK: - Unit score card

struct UnitScoreCard: View {
    let unit: String
    let correct: Int
    let total: Int

    private var pct: Double { Double(correct) / Double(total) }
    private var tint: Color { pct >= 2/3 ? .green : pct >= 1/3 ? .yellow : .red }
    private var label: String { pct >= 2/3 ? "Strong" : pct >= 1/3 ? "Review" : "Weak" }

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text(unit).font(.body.weight(.medium))
                Text("\(correct) / \(total) correct").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            ProgressView(value: pct)
                .tint(tint)
                .frame(width: 80)
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 44)
        }
        .padding(10)
        .background(tint.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Rapid review (flashcards)

struct RapidReviewView: View {
    let weakUnits: [String]

    private let allUnits = ["Unit 1","Unit 2","Unit 3","Unit 4","Unit 5","Unit 6","Unit 7"]
    @State private var selectedUnit: String = "Unit 1"
    @State private var cardIndex   = 0
    @State private var isFlipped   = false
    @State private var flipDegrees = 0.0

    private var displayUnits: [String] { weakUnits.isEmpty ? allUnits : weakUnits + allUnits.filter { !weakUnits.contains($0) } }
    private var cards: [CramCard] { cramCards[selectedUnit] ?? [] }
    private var currentCard: CramCard? { cards.indices.contains(cardIndex) ? cards[cardIndex] : nil }

    var body: some View {
        VStack(spacing: 0) {
            // Unit picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(displayUnits, id: \.self) { unit in
                        Button {
                            selectedUnit = unit; cardIndex = 0; resetFlip()
                        } label: {
                            HStack(spacing: 4) {
                                if weakUnits.contains(unit) {
                                    Circle().fill(.orange).frame(width: 6, height: 6)
                                }
                                Text(unit).font(.caption.weight(.medium))
                            }
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(selectedUnit == unit ? unitColor(unit) : Color.secondary.opacity(0.12))
                            .foregroundStyle(selectedUnit == unit ? .white : .primary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
            }
            Divider()

            if let card = currentCard {
                VStack(spacing: 20) {
                    // Card counter
                    Text("\(cardIndex + 1) / \(cards.count)")
                        .font(.caption).foregroundStyle(.secondary).padding(.top, 16)

                    // Flip card
                    ZStack {
                        // Front
                        flashSide(
                            text: card.term,
                            label: "TERM",
                            color: unitColor(selectedUnit),
                            opacity: isFlipped ? 0 : 1
                        )
                        .rotation3DEffect(.degrees(isFlipped ? -180 : 0), axis: (0,1,0), perspective: 0.5)

                        // Back
                        flashSide(
                            text: card.definition,
                            label: "DEFINITION",
                            color: .secondary,
                            opacity: isFlipped ? 1 : 0
                        )
                        .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (0,1,0), perspective: 0.5)
                    }
                    .frame(height: 220)
                    .padding(.horizontal, 24)
                    .onTapGesture { flipCard() }

                    Text(isFlipped ? "Tap to see the term" : "Tap to reveal definition")
                        .font(.caption).foregroundStyle(.secondary)

                    // Navigation
                    HStack(spacing: 24) {
                        Button {
                            if cardIndex > 0 { cardIndex -= 1; resetFlip() }
                        } label: {
                            Label("Previous", systemImage: "chevron.left")
                        }
                        .buttonStyle(.bordered)
                        .disabled(cardIndex == 0)

                        Button { flipCard() } label: {
                            Label(isFlipped ? "Show Term" : "Show Definition", systemImage: "arrow.left.arrow.right")
                        }
                        .buttonStyle(.bordered)

                        Button {
                            if cardIndex < cards.count - 1 { cardIndex += 1; resetFlip() }
                        } label: {
                            Label("Next", systemImage: "chevron.right")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(cardIndex == cards.count - 1)
                    }

                    Spacer()
                }
            } else {
                ContentUnavailableView("No cards", systemImage: "rectangle.stack")
            }
        }
    }

    @ViewBuilder
    private func flashSide(text: String, label: String, color: Color, opacity: Double) -> some View {
        VStack(spacing: 12) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(color)
                .tracking(1.5)
            Text(text)
                .font(.title3.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color.opacity(0.06))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.25), lineWidth: 1.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(opacity)
    }

    private func flipCard() {
        withAnimation(.spring(duration: 0.4)) {
            isFlipped.toggle()
        }
    }
    private func resetFlip() { isFlipped = false }

    private func unitColor(_ u: String) -> Color {
        switch u {
        case "Unit 1": return .blue; case "Unit 2": return .orange
        case "Unit 3": return .purple; case "Unit 4": return .red
        case "Unit 5": return .brown; case "Unit 6": return .teal
        case "Unit 7": return .indigo; default: return .gray
        }
    }
}

// MARK: - Exam-day guide

struct ExamDayGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Exam-Day Guide")
                    .font(.largeTitle.bold())
                    .padding(.top, 4)

                // Timeline
                GuideSection(icon: "clock.fill", color: .blue, title: "Timing Strategy") {
                    VStack(alignment: .leading, spacing: 6) {
                        tipRow("📝", "Section I — MC: 75 min for 60 questions (~75 sec/question)")
                        tipRow("✏️", "Section II — FRQ: 75 min for 3 questions (~25 min each)")
                        tipRow("⏭️", "Flag and skip hard MC questions; return at the end")
                        tipRow("🕐", "Leave 5 min at the end of each section to review")
                    }
                }

                // FRQ structure
                GuideSection(icon: "pencil.and.outline", color: .purple, title: "FRQ Writing Formula") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach([
                            ("1. Geographic Context", "Define the concept or place in 1–2 sentences."),
                            ("2. Direct Response",    "Answer the prompt directly using course vocabulary."),
                            ("3. Specific Example",   "Name a real country, city, or case study."),
                            ("4. So What (Impact)",   "Explain why it matters geographically."),
                        ], id: \.0) { step, desc in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(step).font(.subheadline.weight(.semibold))
                                Text(desc).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // What to bring
                GuideSection(icon: "bag.fill", color: .brown, title: "What to Bring") {
                    VStack(alignment: .leading, spacing: 5) {
                        tipRow("✅", "Valid government/school photo ID")
                        tipRow("✅", "Several #2 pencils + a black/dark-blue pen")
                        tipRow("✅", "Water bottle and a light snack (for the break)")
                        tipRow("✅", "Comfortable layers (exam rooms vary in temperature)")
                        tipRow("🚫", "No calculator, phone, or smartwatch allowed")
                    }
                }

                // High-yield vocab
                GuideSection(icon: "text.quote", color: .indigo, title: "Last-Minute Vocab Hits") {
                    let terms: [(String, String)] = [
                        ("DTM Stage 2", "↓ death rate, high birth rate → fastest pop. growth"),
                        ("Superimposed boundary", "Drawn without regard to existing cultural divisions"),
                        ("Von Thünen Ring 1", "Dairy/perishables — closest to market city"),
                        ("Rank-size rule", "nth city = 1/n the population of the largest city"),
                        ("Relocation diffusion", "Spread through physical migration of people"),
                        ("HDI", "Life expectancy + education + GNI per capita (UNDP)"),
                        ("Devolution", "Central gov't transfers power to regional gov'ts"),
                        ("EPZ/SEZ", "Lower taxes & regulations to attract foreign investment"),
                    ]
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(terms, id: \.0) { term, def in
                            HStack(alignment: .top, spacing: 6) {
                                Text(term).font(.caption.weight(.bold)).foregroundStyle(.primary).frame(width: 160, alignment: .leading)
                                Text(def).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // Mindset
                GuideSection(icon: "brain.head.profile", color: .green, title: "Mindset") {
                    VStack(alignment: .leading, spacing: 5) {
                        tipRow("🧠", "Trust your prep — you know this material")
                        tipRow("💨", "If you blank on a term, describe it in your own words")
                        tipRow("📍", "Always use specific place names and vocabulary in FRQs")
                        tipRow("😤", "Eliminate obviously wrong MC answers first")
                        tipRow("🎯", "Every question is worth 1 point — no penalty for guessing")
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(24)
        }
    }

    private func tipRow(_ emoji: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(emoji).font(.body)
            Text(text).font(.subheadline).foregroundStyle(.secondary)
        }
    }
}

struct GuideSection<Content: View>: View {
    let icon: String
    let color: Color
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.white)
                    .font(.caption.weight(.semibold))
                    .frame(width: 24, height: 24)
                    .background(color.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Text(title).font(.headline)
            }
            content()
        }
        .padding(16)
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Placement questions (21 total, 3 per unit)

private let placementQuestions: [PlacementQuestion] = [
    // Unit 1
    PlacementQuestion(id: 0, unit: "Unit 1",
        question: "Which map projection is most useful to navigators because it preserves compass bearings (rhumb lines)?",
        options: ["Robinson", "Mercator", "Goode's Homolosine", "Winkel Tripel"],
        correctIndex: 1,
        explanation: "The Mercator projection is conformal — it preserves angles and compass directions — making it ideal for marine navigation despite extreme area distortion near the poles."),
    PlacementQuestion(id: 1, unit: "Unit 1",
        question: "The Chicago metro area, where surrounding suburbs are linked by commuter flows to the city center, is best described as a:",
        options: ["Formal region", "Vernacular region", "Functional region", "Cultural region"],
        correctIndex: 2,
        explanation: "A functional (nodal) region is organised around a central node—here Chicago—connected to its surroundings by flows of people, goods, or information."),
    PlacementQuestion(id: 2, unit: "Unit 1",
        question: "A geographer places one dot on a map for every 1,000 people in each census tract. This is a:",
        options: ["Choropleth map", "Isoline map", "Dot distribution map", "Cartogram"],
        correctIndex: 2,
        explanation: "Dot distribution maps show the location of a phenomenon by placing dots where it occurs. Each dot represents a fixed quantity, making them ideal for population distribution."),
    // Unit 2
    PlacementQuestion(id: 3, unit: "Unit 2",
        question: "According to the Demographic Transition Model, which stage features HIGH birth rates and RAPIDLY DECLINING death rates?",
        options: ["Stage 1", "Stage 2", "Stage 3", "Stage 4"],
        correctIndex: 1,
        explanation: "Stage 2 sees death rates fall sharply due to improved medicine and sanitation while birth rates remain high, producing the fastest population growth of any stage."),
    PlacementQuestion(id: 4, unit: "Unit 2",
        question: "Ravenstein's Laws of Migration primarily state that most migrants:",
        options: ["Are young men who move permanently abroad", "Move short distances in steps toward a larger city", "Flee political persecution", "Are unskilled workers seeking factory jobs"],
        correctIndex: 1,
        explanation: "Ravenstein (1885) found that migrants tend to travel short distances in a step-wise pattern—rural area to small town, then to city—with counter-streams flowing in reverse."),
    PlacementQuestion(id: 5, unit: "Unit 2",
        question: "A population pyramid with a wide base tapering sharply upward most likely represents a country in:",
        options: ["Stage 4 of the DTM", "Stage 2 of the DTM", "Negative population growth", "Post-industrial decline"],
        correctIndex: 1,
        explanation: "A wide base indicates high birth rates; the sharp taper shows elevated mortality in older cohorts — classic Stage 2 characteristics found in many developing nations today."),
    // Unit 3
    PlacementQuestion(id: 6, unit: "Unit 3",
        question: "The spread of Islam from Arabia to Southeast Asia along trade routes best illustrates:",
        options: ["Contagious diffusion", "Hierarchical diffusion", "Relocation diffusion", "Stimulus diffusion"],
        correctIndex: 2,
        explanation: "Relocation diffusion occurs when people physically migrate and carry their culture with them. Arab traders settling in Southeast Asia brought Islam through migration."),
    PlacementQuestion(id: 7, unit: "Unit 3",
        question: "Terraced rice paddies carved into Philippine hillsides are best described as a:",
        options: ["Physical landscape", "Cultural landscape", "Relic landscape", "Formal region"],
        correctIndex: 1,
        explanation: "A cultural landscape is the visible imprint of human activity on the natural environment. The terraces are a direct human modification built over centuries for agriculture."),
    PlacementQuestion(id: 8, unit: "Unit 3",
        question: "Stimulus diffusion best describes a situation where:",
        options: ["A fashion trend spreads from Paris to rural towns", "McDonald's adapts its menu for local tastes worldwide", "Immigrants carry religion to a new country", "Smartphones spread globally within a decade"],
        correctIndex: 1,
        explanation: "Stimulus diffusion: the underlying concept spreads but is adapted, not copied exactly. McDonald's localising its menu (e.g., McAloo Tikki in India) is the textbook example."),
    // Unit 4
    PlacementQuestion(id: 9, unit: "Unit 4",
        question: "The Kurdish people — who share a distinct language and culture but lack their own sovereign state — are best described as a:",
        options: ["Nation-state", "Multinational state", "Stateless nation", "Multi-state nation"],
        correctIndex: 2,
        explanation: "A stateless nation is a cultural/ethnic group without its own sovereign state. The Kurds are distributed across Turkey, Iraq, Syria, and Iran with no independent country."),
    PlacementQuestion(id: 10, unit: "Unit 4",
        question: "A boundary drawn by an outside power without regard to existing ethnic or cultural divisions is called a(n):",
        options: ["Subsequent boundary", "Antecedent boundary", "Superimposed boundary", "Relic boundary"],
        correctIndex: 2,
        explanation: "Superimposed boundaries are imposed on regions by external powers, ignoring existing cultural patterns. African borders drawn at the 1884–85 Berlin Conference are the prime example."),
    PlacementQuestion(id: 11, unit: "Unit 4",
        question: "The transfer of political power from a central government to regional or local governments is called:",
        options: ["Balkanization", "Devolution", "Supranationalism", "Gerrymandering"],
        correctIndex: 1,
        explanation: "Devolution is the process by which central authority cedes power downward to regional governments. Examples include Scotland's parliament and Spain's autonomous communities."),
    // Unit 5
    PlacementQuestion(id: 12, unit: "Unit 5",
        question: "In Von Thünen's model, which land use appears in Ring 1, closest to the central market?",
        options: ["Grain farming", "Ranching", "Dairy and perishable crops", "Forestry"],
        correctIndex: 2,
        explanation: "Dairy and market gardens (perishables) occupy Ring 1 because they are the most time-sensitive and must minimise transport cost and spoilage time to market."),
    PlacementQuestion(id: 13, unit: "Unit 5",
        question: "The Green Revolution primarily increased crop yields through:",
        options: ["Traditional organic farming methods", "Land redistribution to smallholders", "High-yield variety seeds, fertilisers, and irrigation", "Shifting cultivation on new land"],
        correctIndex: 2,
        explanation: "The Green Revolution (1960s–70s) used HYV seeds (especially wheat and rice), synthetic fertilisers, pesticides, and mechanised irrigation to dramatically raise yields in South and Southeast Asia."),
    PlacementQuestion(id: 14, unit: "Unit 5",
        question: "Subsistence agriculture is distinguished from commercial agriculture primarily because subsistence farmers:",
        options: ["Use more machinery and technology", "Grow crops primarily to feed themselves and their families", "Operate on smaller plots with lower yields per acre", "Sell crops on global commodity markets"],
        correctIndex: 1,
        explanation: "Subsistence farmers produce food primarily to feed themselves and their households, with little or no marketable surplus. Commercial agriculture is driven by market production and profit."),
    // Unit 6
    PlacementQuestion(id: 15, unit: "Unit 6",
        question: "In Burgess's Concentric Zone Model, Zone 2 (the zone in transition) is typically characterised by:",
        options: ["High-end residential housing", "Light industry, deteriorating housing, and recent immigrants", "Suburban single-family commuter homes", "Central Business District offices"],
        correctIndex: 1,
        explanation: "Zone 2 features older deteriorating housing, light manufacturing, and is often home to newly arrived immigrants and lower-income residents who cannot afford outer zones."),
    PlacementQuestion(id: 16, unit: "Unit 6",
        question: "Gentrification most directly results in:",
        options: ["Population decline in inner cities", "Rising property values and displacement of lower-income residents", "Suburban sprawl and edge-city growth", "Deindustrialisation of urban cores"],
        correctIndex: 1,
        explanation: "Gentrification brings wealthier residents and investment into lower-income urban neighbourhoods, raising property values and often displacing long-term residents who can no longer afford the area."),
    PlacementQuestion(id: 17, unit: "Unit 6",
        question: "According to the rank-size rule, if a country's largest city has 8 million people, its third-largest city will have approximately:",
        options: ["4 million", "2.67 million", "2 million", "1 million"],
        correctIndex: 1,
        explanation: "Rank-size rule: nth city = 1/n × largest. So 3rd city = 1/3 × 8 million ≈ 2.67 million. The rule describes a logarithmic distribution typical of economically advanced countries."),
    // Unit 7
    PlacementQuestion(id: 18, unit: "Unit 7",
        question: "In Wallerstein's World Systems Theory, periphery countries are primarily characterised by:",
        options: ["High-tech manufacturing and financial services", "Raw material export and low-wage labour-intensive industry", "Post-industrial knowledge economies", "Diversified economies with emerging markets"],
        correctIndex: 1,
        explanation: "Periphery countries supply raw materials and cheap labour to core countries, retaining little of the economic surplus generated. Core countries capture most profits through capital and technology."),
    PlacementQuestion(id: 19, unit: "Unit 7",
        question: "The UN's Human Development Index (HDI) is composed of which three dimensions?",
        options: ["GDP, military strength, and trade balance", "Life expectancy, education, and GNI per capita", "Urbanisation rate, literacy rate, and fertility rate", "Democracy, press freedom, and income equality"],
        correctIndex: 1,
        explanation: "HDI = life expectancy (health) + mean/expected years of schooling (education) + GNI per capita (standard of living). Published annually by the UNDP."),
    PlacementQuestion(id: 20, unit: "Unit 7",
        question: "Export Processing Zones (EPZs) and Special Economic Zones (SEZs) are primarily designed to:",
        options: ["Protect domestic industries from foreign competition", "Attract foreign direct investment through tax incentives and relaxed regulations", "Control agricultural commodity exports", "Restrict immigration into industrialised regions"],
        correctIndex: 1,
        explanation: "EPZs/SEZs offer reduced taxes, relaxed labour and environmental regulations, and streamlined bureaucracy to attract multinational corporations. Common in periphery and semi-periphery countries."),
]

// MARK: - Cram cards (8 per unit)

private let cramCards: [String: [CramCard]] = [
    "Unit 1": [
        CramCard(unit:"Unit 1", term:"Map Projection",         definition:"A method of representing Earth's curved surface on a flat map. All projections distort at least one property: shape, area, distance, or direction."),
        CramCard(unit:"Unit 1", term:"Formal Region",          definition:"An area defined by a common measurable characteristic such as language, climate, or political boundary. Example: the French-speaking province of Québec."),
        CramCard(unit:"Unit 1", term:"Functional Region",      definition:"An area organised around a central node by flows of people, goods, or information. Example: the New York City commuter zone."),
        CramCard(unit:"Unit 1", term:"Vernacular Region",      definition:"A region defined by popular perception or cultural identity rather than formal data. Example: 'The South' or 'The Bible Belt.'"),
        CramCard(unit:"Unit 1", term:"GIS",                    definition:"Geographic Information System — software that captures, stores, and analyses spatial data layers for decision-making and mapping."),
        CramCard(unit:"Unit 1", term:"Remote Sensing",         definition:"Collecting data about Earth's surface from a distance, typically using satellite or aerial imagery. No direct physical contact required."),
        CramCard(unit:"Unit 1", term:"Mercator Projection",    definition:"A conformal (shape-preserving) cylindrical projection. Preserves compass bearings (rhumb lines) but greatly distorts area near the poles."),
        CramCard(unit:"Unit 1", term:"Scale",                  definition:"The ratio of map distance to real-world distance. Large-scale = more detail, smaller area shown. Small-scale = less detail, larger area."),
    ],
    "Unit 2": [
        CramCard(unit:"Unit 2", term:"DTM — Stage 2",          definition:"Death rates fall sharply (improved sanitation/medicine); birth rates remain high → fastest population growth. Most LDCs passed through this stage."),
        CramCard(unit:"Unit 2", term:"Total Fertility Rate",   definition:"Average number of children a woman would have in her lifetime. Replacement-level TFR ≈ 2.1 in MDCs."),
        CramCard(unit:"Unit 2", term:"Dependency Ratio",       definition:"Ratio of dependents (under 15 + over 64) to the working-age population (15–64). A high ratio strains social services."),
        CramCard(unit:"Unit 2", term:"Push Factors",           definition:"Negative conditions driving emigration: poverty, war, famine, natural disasters, political persecution."),
        CramCard(unit:"Unit 2", term:"Pull Factors",           definition:"Positive conditions attracting immigrants: economic opportunity, political freedom, family reunification, better climate."),
        CramCard(unit:"Unit 2", term:"Ravenstein's Laws",      definition:"Most migrants move short distances in steps; counter-streams exist; females dominate short-distance migration; most migrants are young adults."),
        CramCard(unit:"Unit 2", term:"Malthusian Theory",      definition:"Malthus (1798): population grows geometrically, food supply arithmetically → eventual famine unless restrained by preventive or positive checks."),
        CramCard(unit:"Unit 2", term:"Brain Drain",            definition:"Emigration of educated, skilled workers from developing to developed countries, depriving origin countries of human capital."),
    ],
    "Unit 3": [
        CramCard(unit:"Unit 3", term:"Cultural Landscape",     definition:"The visible modification of the natural landscape by human cultural activity — buildings, roads, field patterns, religious structures."),
        CramCard(unit:"Unit 3", term:"Folk Culture",           definition:"Culture practised by a small, homogeneous group living in relative isolation with slow cultural change and strong ties to place."),
        CramCard(unit:"Unit 3", term:"Popular Culture",        definition:"Culture widely shared across large heterogeneous populations, spread rapidly through mass media and technology; changes quickly."),
        CramCard(unit:"Unit 3", term:"Relocation Diffusion",   definition:"Spread of a cultural trait through physical migration of people. Example: immigrants carrying language and religion to new countries."),
        CramCard(unit:"Unit 3", term:"Contagious Diffusion",   definition:"Spread from person to person through direct contact, like a disease — nearly all people in an area are susceptible. Example: social media trends."),
        CramCard(unit:"Unit 3", term:"Hierarchical Diffusion", definition:"Spread from most influential to least, top-down. Example: fashion trends moving from fashion capitals to smaller cities and rural areas."),
        CramCard(unit:"Unit 3", term:"Stimulus Diffusion",     definition:"The underlying concept diffuses but the specific form is adapted locally. Example: McDonald's adapts its menu for different cultures."),
        CramCard(unit:"Unit 3", term:"Syncretism",             definition:"Blending of two or more cultural traditions into a new form. Example: Candomblé (African religions + Catholicism in Brazil)."),
    ],
    "Unit 4": [
        CramCard(unit:"Unit 4", term:"Nation-State",           definition:"A political unit where a single nation (ethnic/cultural group) and a state (sovereign country) coincide. Example: Japan, Iceland."),
        CramCard(unit:"Unit 4", term:"Stateless Nation",       definition:"An ethnic/cultural group without its own sovereign state. Classic example: the Kurds, spread across Turkey, Iraq, Syria, and Iran."),
        CramCard(unit:"Unit 4", term:"Multinational State",    definition:"A single state containing multiple ethnic nationalities. Examples: Canada, Russia, Nigeria."),
        CramCard(unit:"Unit 4", term:"Superimposed Boundary",  definition:"A boundary drawn by outside powers without regard to existing cultural/ethnic patterns. African borders from the 1884–85 Berlin Conference."),
        CramCard(unit:"Unit 4", term:"Antecedent Boundary",    definition:"A boundary drawn before the area was heavily settled. Example: the US–Canada border along the 49th parallel."),
        CramCard(unit:"Unit 4", term:"Devolution",             definition:"Transfer of power from a central government to regional or local governments. Examples: Scottish Parliament, Catalan autonomy."),
        CramCard(unit:"Unit 4", term:"Supranationalism",       definition:"Nations voluntarily cede some sovereignty to a higher political/economic body. Example: the European Union, NATO."),
        CramCard(unit:"Unit 4", term:"Balkanization",          definition:"Fragmentation of a larger region into smaller, often hostile political units — named after the breakup of former Yugoslavia."),
    ],
    "Unit 5": [
        CramCard(unit:"Unit 5", term:"Von Thünen Model",       definition:"Concentric rings of land use around a market city. Ring 1: dairy/perishables; Ring 2: forest/wood; Ring 3: grain; Ring 4: ranching. Distance from market determines use."),
        CramCard(unit:"Unit 5", term:"Green Revolution",       definition:"1960s–70s introduction of high-yield variety seeds, chemical fertilisers, pesticides, and irrigation — dramatically raising yields in South/SE Asia."),
        CramCard(unit:"Unit 5", term:"Subsistence Agriculture",definition:"Farming primarily to feed the farmer's own family with little or no surplus for market sale. Common in LDCs."),
        CramCard(unit:"Unit 5", term:"Commercial Agriculture", definition:"Large-scale farming oriented toward market sale and profit; uses mechanisation and monoculture. Common in MDCs."),
        CramCard(unit:"Unit 5", term:"Intensive Agriculture",  definition:"High labour/capital inputs per unit of land to maximise yield. Example: paddy rice farming in East and Southeast Asia."),
        CramCard(unit:"Unit 5", term:"Extensive Agriculture",  definition:"Low inputs per unit of land over a large area. Example: ranching across the Great Plains of North America."),
        CramCard(unit:"Unit 5", term:"GMO",                    definition:"Genetically Modified Organism — crops engineered for disease resistance, higher yields, or herbicide tolerance. Economically and ecologically controversial."),
        CramCard(unit:"Unit 5", term:"Land Tenure",            definition:"The system by which land is owned or accessed (communal, private, leasehold). Affects farmer investment incentives and productivity."),
    ],
    "Unit 6": [
        CramCard(unit:"Unit 6", term:"Primate City",           definition:"The largest city in a country, disproportionately large relative to the second city (typically > 2×). Examples: Bangkok, Mexico City, Buenos Aires."),
        CramCard(unit:"Unit 6", term:"Rank-Size Rule",         definition:"The nth largest city has 1/n the population of the largest city. Describes a logarithmic city-size distribution common in economically mature countries."),
        CramCard(unit:"Unit 6", term:"Burgess Concentric Zone",definition:"CBD → Zone of Transition → Working-class residential → Middle-class residential → Commuter zone. Developed by Ernest Burgess using Chicago."),
        CramCard(unit:"Unit 6", term:"Hoyt Sector Model",      definition:"Land use radiates outward in pie-shaped sectors along transport routes (highways, railroads), not concentric rings. Homer Hoyt, 1939."),
        CramCard(unit:"Unit 6", term:"Multiple Nuclei Model",  definition:"A city develops around multiple nodes (Harris & Ullman, 1945), each specialising in different functions; no single dominant CBD."),
        CramCard(unit:"Unit 6", term:"Gentrification",         definition:"Wealthier residents and investment flow into lower-income urban neighbourhoods, raising property values and often displacing original residents."),
        CramCard(unit:"Unit 6", term:"Squatter Settlement",    definition:"Informal housing built on land without legal title, often at the city periphery. Called favelas (Brazil), barrios, or bidonvilles."),
        CramCard(unit:"Unit 6", term:"Smart Growth",           definition:"Urban planning strategy favouring compact, transit-oriented, walkable development to limit sprawl and reduce environmental impact."),
    ],
    "Unit 7": [
        CramCard(unit:"Unit 7", term:"Primary Sector",         definition:"Raw material extraction: farming, fishing, mining, forestry. Dominant employer in periphery countries."),
        CramCard(unit:"Unit 7", term:"Secondary Sector",       definition:"Manufacturing and processing of raw materials into finished goods. Grew with industrialisation."),
        CramCard(unit:"Unit 7", term:"Tertiary Sector",        definition:"Service industries: retail, healthcare, education, transportation. Dominant sector in MDCs."),
        CramCard(unit:"Unit 7", term:"Quaternary/Quinary",     definition:"Quaternary = knowledge economy (research, IT, finance). Quinary = top-level decision-making. Both concentrated in core countries."),
        CramCard(unit:"Unit 7", term:"HDI",                    definition:"Human Development Index: composite of life expectancy + education (mean & expected years of schooling) + GNI per capita. Published by UNDP annually."),
        CramCard(unit:"Unit 7", term:"Core-Periphery (Wallerstein)", definition:"Core countries dominate through capital and technology; periphery countries supply cheap labour and raw materials; semi-periphery are in between."),
        CramCard(unit:"Unit 7", term:"Rostow's Stages",        definition:"5 stages of economic growth: 1 Traditional, 2 Pre-conditions, 3 Takeoff (industrialisation begins), 4 Drive to Maturity, 5 High Mass Consumption."),
        CramCard(unit:"Unit 7", term:"EPZ / SEZ",              definition:"Export Processing Zone / Special Economic Zone — areas with reduced taxes, regulations, and tariffs to attract foreign direct investment."),
    ],
]
