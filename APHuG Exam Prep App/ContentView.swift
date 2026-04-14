//
//  ContentView.swift
//  APHuG Exam Prep App
//
//  Created by apmckelvey on 4/14/26.
//

import SwiftUI

enum SidebarItem: String, Hashable, CaseIterable {
    case studyPlan = "Study Plan"
    case textbook = "Textbook"

    var icon: String {
        switch self {
        case .studyPlan: return "calendar"
        case .textbook: return "book.fill"
        }
    }
}

struct ContentView: View {
    @State private var selectedSidebar: SidebarItem? = .studyPlan
    @State private var studyDays: [StudyDay] = StudyDay.loadFromCSV()
    @State private var selectedDay: StudyDay?
    @State private var refreshID = UUID()

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(SidebarItem.allCases, id: \.self, selection: $selectedSidebar) { item in
                Label(item.rawValue, systemImage: item.icon)
            }
            .navigationTitle("APHuG Prep")
            .listStyle(.sidebar)
        } content: {
            // Content area based on sidebar selection
            switch selectedSidebar {
            case .studyPlan:
                StudyPlanView(studyDays: $studyDays, selectedDay: $selectedDay)
                    .id(refreshID)
            case .textbook:
                TextbookView()
            case nil:
                Text("Select an item from the sidebar")
                    .foregroundStyle(.secondary)
            }
        } detail: {
            // Detail area (only relevant for study plan)
            if selectedSidebar == .studyPlan {
                if let day = selectedDay {
                    DayDetailView(day: day) { isCompleted in
                        // Update completion state and refresh the list
                        if let index = studyDays.firstIndex(where: { $0.id == day.id }) {
                            studyDays[index].isCompleted = isCompleted
                        }
                        refreshID = UUID()
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "hand.point.left.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Select a study day to get started")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                EmptyView()
            }
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}

#Preview {
    ContentView()
}
