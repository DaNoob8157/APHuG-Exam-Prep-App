//
//  SessionDetailView.swift
//  APHuG Exam Prep App
//

import SwiftUI

// MARK: - Detail pane router

struct SessionDetailView: View {
    @ObservedObject var manager: SessionManager

    var body: some View {
        Group {
            if manager.tasks.isEmpty {
                ContentUnavailableView(
                    "No Tasks Loaded",
                    systemImage: "clock",
                    description: Text("Pick a study day in the list on the left.")
                )
            } else if manager.isSessionComplete {
                SessionCompleteView(manager: manager)
            } else if !manager.hasStarted {
                SessionWelcomeView(manager: manager)
            } else {
                ActiveSessionView(manager: manager)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Welcome (not started yet)

struct SessionWelcomeView: View {
    @ObservedObject var manager: SessionManager

    private var totalMinutes: Int { manager.tasks.reduce(0) { $0 + $1.suggestedMinutes } }

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // Live wall clock
            VStack(spacing: 4) {
                Text(Date(), style: .time)
                    .font(.system(size: 64, weight: .thin, design: .monospaced))
                    .monospacedDigit()
                Text(Date(), style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                Text("Ready for Day \(manager.selectedDay)?")
                    .font(.title2.bold())
                if let first = manager.tasks.first {
                    Text(first.unitFocus)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 20) {
                    Label("\(manager.tasks.count) tasks", systemImage: "list.bullet")
                    Label("~\(totalMinutes) min total", systemImage: "clock")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            // Task-type strip
            HStack(spacing: 10) {
                ForEach(Array(manager.tasks.enumerated()), id: \.element.id) { _, task in
                    VStack(spacing: 4) {
                        Image(systemName: task.taskType.icon)
                            .font(.caption)
                            .foregroundStyle(task.taskType.color)
                            .frame(width: 30, height: 30)
                            .background(task.taskType.color.opacity(0.12))
                            .clipShape(Circle())
                        Text("\(task.suggestedMinutes)m")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button {
                manager.clockIn()
            } label: {
                Label("Clock In", systemImage: "play.fill")
                    .font(.title3.weight(.semibold))
                    .padding(.horizontal, 36)
                    .padding(.vertical, 13)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            .keyboardShortcut(.return)

            Spacer()
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Active session

struct ActiveSessionView: View {
    @ObservedObject var manager: SessionManager
    @State private var showTip = false

    private var task: StudyTask? { manager.currentTask }
    private var accent: Color    { task?.taskType.color ?? .blue }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {

                // Top bar: session elapsed + tip button + live clock
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Session")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatTime(manager.totalSessionSeconds))
                            .font(.system(.body, design: .monospaced).weight(.semibold))
                            .monospacedDigit()
                    }
                    Spacer()
                    if manager.isPaused {
                        Label("Paused", systemImage: "pause.circle.fill")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.orange)
                    }
                    Spacer()
                    // Tip popover button
                    Button { showTip.toggle() } label: {
                        Image(systemName: "lightbulb")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Timer tips")
                    .popover(isPresented: $showTip, arrowEdge: .bottom) {
                        TipPopover(
                            title: "Timer Tips",
                            tips: [
                                (icon: "arrow.left.and.right.square",
                                 text: "Drag the left edge of this panel to make the timer view wider — the countdown ring scales with it."),
                                (icon: "arrow.up.backward.and.arrow.down.forward.square",
                                 text: "Press ⌃⌘F to go full-screen for a distraction-free session."),
                                (icon: "return",
                                 text: "Press ↩ (Return) to advance to the next task without reaching for the mouse."),
                                (icon: "pause.fill",
                                 text: "Pause at any time — the clock freezes exactly where you left off."),
                                (icon: "list.bullet",
                                 text: "Click any task row on the left to jump directly to it."),
                                (icon: "exclamationmark.circle",
                                 text: "The ring turns red if you exceed the suggested time, with a +m:ss over-time counter."),
                            ],
                            isPresented: $showTip
                        )
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Now")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(Date(), style: .time)
                            .font(.system(.body, design: .monospaced).weight(.semibold))
                            .monospacedDigit()
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)

                if let task {
                    // Task-type badge
                    Label(
                        task.taskType.isBreak ? "Break Time ☕" : task.taskType.shortName,
                        systemImage: task.taskType.icon
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(accent.gradient)
                    .clipShape(Capsule())

                    // Countdown ring
                    TimerRing(
                        progress:   manager.isOverTime ? 1.0 : manager.taskProgress,
                        color:      manager.isOverTime ? .red : accent,
                        label:      manager.isOverTime
                            ? "+\(formatTime(manager.overTimeSeconds))"
                            : formatTime(manager.timeRemainingSeconds),
                        sublabel:   manager.isOverTime ? "over time" : "remaining"
                    )
                    .frame(width: 230, height: 230)

                    // Task description
                    Text(task.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)

                    // Controls
                    HStack(spacing: 14) {
                        if manager.isRunning {
                            Button { manager.pause() } label: {
                                Label("Pause", systemImage: "pause.fill")
                            }
                            .buttonStyle(.bordered)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        } else {
                            Button { manager.resume() } label: {
                                Label("Resume", systemImage: "play.fill")
                            }
                            .buttonStyle(.bordered)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        }

                        Button { manager.completeAndNext() } label: {
                            Label(
                                task.taskType.isBreak ? "Break Done → Next" : "Done & Next",
                                systemImage: "checkmark.circle.fill"
                            )
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(accent)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .keyboardShortcut(.return)
                    }

                    // Next-up preview
                    if let nextIdx = manager.tasks.indices.first(where: {
                        $0 > manager.currentTaskIndex && !manager.completedIndices.contains($0)
                    }) {
                        let next = manager.tasks[nextIdx]
                        Divider().padding(.horizontal, 40)
                        VStack(spacing: 6) {
                            Text("NEXT UP")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .tracking(1.5)
                            HStack(spacing: 6) {
                                Image(systemName: next.taskType.icon)
                                    .foregroundStyle(next.taskType.color)
                                Text(next.taskType.shortName)
                                    .fontWeight(.medium)
                                Text("·")
                                    .foregroundStyle(.secondary)
                                Text("\(next.suggestedMinutes) min")
                                    .foregroundStyle(.secondary)
                            }
                            .font(.subheadline)
                            Text(next.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 40)
                    }
                }

                Spacer(minLength: 24)
            }
        }
    }

    private func formatTime(_ s: Int) -> String {
        String(format: "%d:%02d", s / 60, s % 60)
    }
}

// MARK: - Session complete

struct SessionCompleteView: View {
    @ObservedObject var manager: SessionManager

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            VStack(spacing: 8) {
                Text("Day \(manager.selectedDay) Complete!")
                    .font(.largeTitle.bold())
                Text("All \(manager.tasks.count) tasks finished.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("Session time: \(formatTime(manager.totalSessionSeconds))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Button { manager.resetDay() } label: {
                Label("Reset Day", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            Spacer()
        }
    }

    private func formatTime(_ s: Int) -> String {
        let h = s / 3600; let m = (s % 3600) / 60; let sec = s % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, sec)
            : String(format: "%d:%02d", m, sec)
    }
}

// MARK: - Timer ring

struct TimerRing: View {
    let progress: Double
    let color: Color
    let label: String
    let sublabel: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.12), lineWidth: 18)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            VStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 42, weight: .bold, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(color)
                Text(sublabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
