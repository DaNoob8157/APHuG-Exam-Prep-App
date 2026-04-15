//
//  OnboardingView.swift
//  APHuG Exam Prep App
//
//  First-launch walkthrough covering every major section of the app.
//  Re-openable at any time via the ? button in the toolbar.
//

import SwiftUI

// MARK: - Page data

struct OnboardingPage: Identifiable {
    let id: Int
    let systemImage: String
    let imageColor: Color
    let title: String
    let subtitle: String
    let tips: [Tip]

    struct Tip: Identifiable {
        let id = UUID()
        let icon: String
        let text: String
    }
}

private let onboardingPages: [OnboardingPage] = [

    // 0 — Welcome
    OnboardingPage(
        id: 0,
        systemImage: "graduationcap.fill",
        imageColor: .blue,
        title: "Welcome to APHuG Prep",
        subtitle: "Your all-in-one macOS study companion for the AP Human Geography exam.",
        tips: [
            .init(icon: "sidebar.left", text: "Use the sidebar on the left to jump between sections."),
            .init(icon: "arrow.left.and.right.square", text: "Drag any column divider left or right to resize it to your liking."),
            .init(icon: "macwindow", text: "Drag a corner of the window to make it as large or small as you need — the app adapts."),
        ]
    ),

    // 1 — Study Plan & My Plan
    OnboardingPage(
        id: 1,
        systemImage: "calendar",
        imageColor: .indigo,
        title: "Study Plan & My Plan",
        subtitle: "\"Study Plan\" shows the built-in 14-day schedule. \"My Plan\" is yours to customise.",
        tips: [
            .init(icon: "hand.point.right", text: "Click any day in the list — its full detail opens in the right panel."),
            .init(icon: "calendar.badge.plus", text: "In My Plan, tap the + button to add a custom day with your own tasks and time blocks."),
            .init(icon: "pencil", text: "Right-click (or swipe) a custom day to edit or delete it."),
            .init(icon: "checkmark.circle", text: "Mark days complete to track your progress. The bar at the top updates live."),
        ]
    ),

    // 2 — Today's Session (timer)
    OnboardingPage(
        id: 2,
        systemImage: "timer",
        imageColor: .teal,
        title: "Today's Session",
        subtitle: "A live countdown timer that walks you through every task in your study day — with built-in breaks.",
        tips: [
            .init(icon: "chevron.left.chevron.right", text: "Use the ◀ Day 3 ▶ arrows to pick which day's schedule to run."),
            .init(icon: "play.fill", text: "Tap \"Clock In\" to start. The circular ring counts down your task time."),
            .init(icon: "pause.fill", text: "Tap \"Pause\" any time — the clock freezes. Tap \"Resume\" to continue."),
            .init(icon: "checkmark.circle.fill", text: "Tap \"Done & Next\" (or press ↩) when you finish a task to advance automatically."),
            .init(icon: "exclamationmark.triangle", text: "The ring turns red if you go over time — it shows exactly how long you've run over."),
            .init(icon: "arrow.up.left.and.arrow.down.right", text: "Widen the detail pane by dragging its left edge — the countdown ring scales with it."),
        ]
    ),

    // 3 — Practice Exams (WebKit)
    OnboardingPage(
        id: 3,
        systemImage: "doc.richtext.fill",
        imageColor: .orange,
        title: "Practice Exams",
        subtitle: "Open 10 curated AP resources right inside the app — no switching windows.",
        tips: [
            .init(icon: "list.bullet", text: "Pick a source in the left list; the site loads in the right panel instantly."),
            .init(icon: "arrow.left", text: "Use the ← → toolbar buttons to navigate back and forward within the site."),
            .init(icon: "arrow.clockwise", text: "Tap the reload button (↻) if a page gets stuck."),
            .init(icon: "arrow.up.right.square", text: "Tap \"Open in Chrome\" in the toolbar to pop any site into Chrome for a bigger view."),
            .init(icon: "arrow.left.and.right.square", text: "Drag the divider between the source list and the browser to give the web view more space."),
            .init(icon: "tag", text: "Use the tag chips (MC, FRQ, Free, Official…) to filter sources by type."),
        ]
    ),

    // 4 — Cram Mode
    OnboardingPage(
        id: 4,
        systemImage: "flame.fill",
        imageColor: .red,
        title: "Cram Mode",
        subtitle: "Three power tools for the day of the test: diagnostic quiz, flashcards, and an exam-day guide.",
        tips: [
            .init(icon: "target", text: "Start with the Diagnostic Quiz (21 Qs, 3 per unit) to find your weak spots before you sit down."),
            .init(icon: "rectangle.stack.fill", text: "Tap a flashcard to flip it — swipe or click Next/Previous to move through the deck."),
            .init(icon: "exclamationmark.circle.fill", text: "Weak units (scored < 2/3) appear first in the flashcard unit picker, highlighted in orange."),
            .init(icon: "doc.text.fill", text: "Check the Exam-Day Guide for FRQ formula, timing strategy, and what to bring."),
        ]
    ),

    // 5 — Music (Pandora)
    OnboardingPage(
        id: 5,
        systemImage: "music.note",
        imageColor: .pink,
        title: "Study Music — Pandora",
        subtitle: "Pick a study station and Pandora loads right inside the app so you never break focus.",
        tips: [
            .init(icon: "music.note.list", text: "Choose any station from the list — Lo-Fi, Classical, Ambient, Jazz, and more."),
            .init(icon: "arrow.up.right.square", text: "Tap \"Open in Chrome\" to move Pandora to a Chrome window if you prefer."),
            .init(icon: "arrow.left.and.right.square", text: "Drag the left edge of the Pandora pane to make more room for the player."),
            .init(icon: "speaker.wave.2", text: "Pandora requires a free account — sign up or log in once and it remembers you."),
        ]
    ),

    // 6 — Window & layout tips
    OnboardingPage(
        id: 6,
        systemImage: "macwindow.on.rectangle",
        imageColor: .purple,
        title: "Resizing & Layout Tips",
        subtitle: "Everything in the app is resizable — here's the full guide.",
        tips: [
            .init(icon: "sidebar.left",                  text: "Sidebar width — drag the right edge of the sidebar column."),
            .init(icon: "rectangle.split.3x1",           text: "Middle column width — drag the divider between the list and detail panels."),
            .init(icon: "arrow.up.left.and.arrow.down.right", text: "Window size — drag any edge or corner of the app window to resize freely."),
            .init(icon: "arrow.up.backward.and.arrow.down.forward.square", text: "Full screen — press ⌃⌘F or use the green traffic-light button."),
            .init(icon: "pip.enter", text: "Split View — drag the green button to snap the app alongside another window."),
            .init(icon: "questionmark.circle", text: "Tap the ? button in the toolbar any time to return to this guide."),
        ]
    ),
]

// MARK: - Onboarding sheet

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var pageIndex = 0

    private var page: OnboardingPage { onboardingPages[pageIndex] }
    private var isLast: Bool { pageIndex == onboardingPages.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            // Top: icon + title
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(page.imageColor.opacity(0.12))
                        .frame(width: 100, height: 100)
                    Image(systemName: page.systemImage)
                        .font(.system(size: 46))
                        .foregroundStyle(page.imageColor)
                }
                .padding(.top, 32)

                VStack(spacing: 6) {
                    Text(page.title)
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    Text(page.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 32)
            }

            Divider()
                .padding(.vertical, 16)

            // Tips list
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(page.tips) { tip in
                        HStack(alignment: .top, spacing: 14) {
                            Image(systemName: tip.icon)
                                .font(.body)
                                .foregroundStyle(page.imageColor)
                                .frame(width: 26)
                            Text(tip.text)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 32)
                    }
                }
                .padding(.bottom, 8)
            }

            Divider()
                .padding(.top, 8)

            // Bottom navigation
            HStack {
                // Page dots
                HStack(spacing: 6) {
                    ForEach(onboardingPages.indices, id: \.self) { i in
                        Circle()
                            .fill(i == pageIndex ? page.imageColor : Color.secondary.opacity(0.3))
                            .frame(width: i == pageIndex ? 8 : 6, height: i == pageIndex ? 8 : 6)
                            .animation(.spring(duration: 0.25), value: pageIndex)
                    }
                }

                Spacer()

                // Back
                if pageIndex > 0 {
                    Button("← Back") {
                        withAnimation(.easeInOut(duration: 0.2)) { pageIndex -= 1 }
                    }
                    .buttonStyle(.bordered)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }

                // Next / Done
                Button(isLast ? "Get Started" : "Next →") {
                    if isLast {
                        isPresented = false
                        UserDefaults.standard.set(true, forKey: "onboarding_completed_v1")
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) { pageIndex += 1 }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(page.imageColor)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .keyboardShortcut(isLast ? KeyboardShortcut(.return) : .init("\u{f702}", modifiers: []))   // ↩ on last page
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 18)
        }
        .frame(width: 520, height: 580)
        .animation(.easeInOut(duration: 0.2), value: pageIndex)
    }
}

// MARK: - Small tip popover (used on individual views)

struct TipPopover: View {
    let title: String
    let tips: [(icon: String, text: String)]
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Label(title, systemImage: "lightbulb.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.yellow)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                ForEach(tips.indices, id: \.self) { i in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: tips[i].icon)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(width: 22)
                        Text(tips[i].text)
                            .font(.callout)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(14)
        }
        .frame(width: 320)
    }
}
