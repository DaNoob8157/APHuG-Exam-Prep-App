//
//  CustomPlanView.swift
//  APHuG Exam Prep App
//
//  Lets users create, edit, and delete their own study days alongside the built-in 14-day plan.
//

import SwiftUI

// MARK: - Main list view (content pane)

struct CustomPlanView: View {
    @Binding var days: [CustomStudyDay]
    @Binding var selectedDay: CustomStudyDay?

    @State private var showingAddSheet  = false
    @State private var editingDay: CustomStudyDay? = nil

    var completedCount: Int { days.filter { $0.isCompleted }.count }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("My Study Plan")
                            .font(.headline)
                        Text("Your personal schedule alongside the default 14-day plan.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        editingDay   = nil
                        showingAddSheet = true
                    } label: {
                        Label("Add Day", systemImage: "plus.circle.fill")
                            .font(.subheadline.weight(.medium))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                if !days.isEmpty {
                    ProgressView(value: Double(completedCount), total: Double(days.count))
                        .tint(.blue)
                    Text("\(completedCount) of \(days.count) days complete")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            if days.isEmpty {
                Spacer()
                VStack(spacing: 14) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 52))
                        .foregroundStyle(.secondary)
                    Text("No custom days yet")
                        .font(.title3.weight(.medium))
                    Text("Tap \"Add Day\" to build your own study schedule.\nIt lives alongside the default 14-day plan.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add Your First Day", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
                Spacer()
            } else {
                List(days, id: \.id, selection: $selectedDay) { day in
                    CustomDayRow(day: day)
                        .tag(day)
                        .contentShape(Rectangle())
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) { deleteDay(day) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button { editingDay = day; showingAddSheet = true } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.orange)
                        }
                        .contextMenu {
                            Button { editingDay = day; showingAddSheet = true } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Divider()
                            Button(role: .destructive) { deleteDay(day) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                .listStyle(.sidebar)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            EditCustomDaySheet(
                day: editingDay,
                onSave: { saved in
                    if let idx = days.firstIndex(where: { $0.id == saved.id }) {
                        days[idx] = saved
                    } else {
                        days.append(saved)
                    }
                    CustomStudyDay.save(days)
                }
            )
        }
    }

    private func deleteDay(_ day: CustomStudyDay) {
        if selectedDay?.id == day.id { selectedDay = nil }
        days.removeAll { $0.id == day.id }
        CustomStudyDay.save(days)
    }
}

// MARK: - Row

struct CustomDayRow: View {
    let day: CustomStudyDay

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(day.isCompleted ? Color.green : unitColor(for: day.unitFocus))
                    .frame(width: 36, height: 36)
                Image(systemName: day.isCompleted ? "checkmark" : "person.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(day.title.isEmpty ? "Untitled Day" : day.title)
                    .font(.body.weight(.medium))
                HStack(spacing: 6) {
                    Text(day.unitFocus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !day.tasks.isEmpty {
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text("\(day.tasks.count) task\(day.tasks.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text("~\(day.totalMinutes) min")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 3)
    }

    private func unitColor(for unit: String) -> Color {
        switch unit {
        case "Unit 1": return .blue;  case "Unit 2": return .orange
        case "Unit 3": return .purple; case "Unit 4": return .red
        case "Unit 5": return .brown;  case "Unit 6": return .teal
        case "Unit 7": return .indigo; default: return .gray
        }
    }
}

// MARK: - Detail view (detail pane)

struct CustomDayDetailView: View {
    @Binding var day: CustomStudyDay

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(day.title.isEmpty ? "Untitled Day" : day.title)
                            .font(.largeTitle.bold())
                        Text(day.unitFocus)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 6) {
                            Label("\(day.tasks.count) tasks", systemImage: "list.bullet")
                            Text("·")
                            Label("~\(day.totalMinutes) min", systemImage: "clock")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        day.isCompleted.toggle()
                        // Persist
                        var all = CustomStudyDay.load()
                        if let idx = all.firstIndex(where: { $0.id == day.id }) {
                            all[idx] = day
                            CustomStudyDay.save(all)
                        }
                    } label: {
                        Label(
                            day.isCompleted ? "Mark Incomplete" : "Mark Complete",
                            systemImage: day.isCompleted ? "checkmark.circle.fill" : "circle"
                        )
                        .foregroundStyle(day.isCompleted ? .green : .blue)
                    }
                    .buttonStyle(.bordered)
                }

                Divider()

                // Tasks
                if !day.tasks.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tasks")
                            .font(.headline)
                        ForEach(day.tasks) { task in
                            HStack(spacing: 12) {
                                Image(systemName: task.type.icon)
                                    .foregroundStyle(.white)
                                    .font(.caption.weight(.semibold))
                                    .frame(width: 28, height: 28)
                                    .background(taskColor(task.type).gradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(task.type.rawValue)
                                            .font(.body.weight(.medium))
                                        Spacer()
                                        Text("\(task.durationMinutes) min")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    if !task.description.isEmpty {
                                        Text(task.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(10)
                            .background(taskColor(task.type).opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }

                // Notes
                if !day.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        Text(day.notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .background(Color.secondary.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Spacer(minLength: 20)
            }
            .padding(24)
        }
    }

    private func taskColor(_ type: CustomTaskType) -> Color {
        switch type {
        case .study:     return .indigo
        case .practice:  return .orange
        case .frq:       return .pink
        case .review:    return .blue
        case .breakTime: return .green
        case .other:     return .gray
        }
    }
}

// MARK: - Add / Edit sheet

struct EditCustomDaySheet: View {
    @Environment(\.dismiss) private var dismiss

    private var isEditing: Bool { day != nil }

    @State private var draft: CustomStudyDay

    let onSave: (CustomStudyDay) -> Void

    init(day: CustomStudyDay?, onSave: @escaping (CustomStudyDay) -> Void) {
        self._draft  = State(initialValue: day ?? CustomStudyDay())
        self.onSave  = onSave
        self.day     = day
    }
    private let day: CustomStudyDay?

    private let units = ["Unit 1","Unit 2","Unit 3","Unit 4","Unit 5","Unit 6","Unit 7","All Units","Custom"]

    @State private var showingTaskBuilder = false

    var body: some View {
        NavigationStack {
            Form {
                // Basic info
                Section("Day Info") {
                    TextField("Title (e.g. Day 15 — Unit 3 Review)", text: $draft.title)
                    Picker("Unit Focus", selection: $draft.unitFocus) {
                        ForEach(units, id: \.self) { Text($0).tag($0) }
                    }
                }

                // Tasks
                Section {
                    ForEach($draft.tasks) { $task in
                        TaskEditorRow(task: $task)
                    }
                    .onDelete { draft.tasks.remove(atOffsets: $0) }
                    .onMove  { draft.tasks.move(fromOffsets: $0, toOffset: $1) }

                    Button {
                        draft.tasks.append(CustomTask())
                    } label: {
                        Label("Add Task", systemImage: "plus.circle")
                    }
                } header: {
                    HStack {
                        Text("Tasks")
                        Spacer()
                        Text("\(draft.totalMinutes) min total")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Notes
                Section("Notes (optional)") {
                    TextEditor(text: $draft.notes)
                        .frame(minHeight: 80)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isEditing ? "Edit Day" : "New Study Day")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draft)
                        dismiss()
                    }
                    .disabled(draft.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .frame(minWidth: 480, minHeight: 520)
    }
}

// MARK: - Inline task editor row

struct TaskEditorRow: View {
    @Binding var task: CustomTask

    var body: some View {
        HStack(spacing: 10) {
            Picker("", selection: $task.type) {
                ForEach(CustomTaskType.allCases, id: \.self) { t in
                    Label(t.rawValue, systemImage: t.icon).tag(t)
                }
            }
            .labelsHidden()
            .frame(width: 140)

            TextField("Description", text: $task.description)

            Stepper("\(task.durationMinutes) min", value: $task.durationMinutes, in: 1...120, step: 5)
                .frame(width: 130)
        }
    }
}

// MARK: - Empty detail placeholder

struct CustomPlanWelcomeView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Select a custom day to see its details,\nor add a new one with the + button.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
