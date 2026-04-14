//
//  ContentView.swift
//  APHuG Exam Prep App
//
//  Created by apmckelvey on 4/14/26.
//

import SwiftUI

enum SidebarItem: String, Hashable, CaseIterable {
    case studyPlan     = "Study Plan"
    case customPlan    = "My Plan"
    case session       = "Today's Session"
    case practiceExams = "Practice Exams"
    case cramMode      = "Cram Mode"
    case music         = "Music"
    case resources     = "Resources"
    case textbook      = "Textbook"

    var icon: String {
        switch self {
        case .studyPlan:     return "calendar"
        case .customPlan:    return "calendar.badge.plus"
        case .session:       return "timer"
        case .practiceExams: return "doc.richtext.fill"
        case .cramMode:      return "flame.fill"
        case .music:         return "music.note"
        case .resources:     return "link"
        case .textbook:      return "book.fill"
        }
    }
}

struct ContentView: View {
    @State private var selectedSidebar: SidebarItem? = .studyPlan

    // Onboarding
    @State private var showOnboarding: Bool = !UserDefaults.standard.bool(forKey: "onboarding_completed_v1")

    // Study plan
    @State private var studyDays: [StudyDay] = StudyDay.loadFromCSV()
    @State private var selectedDay: StudyDay?
    @State private var refreshID = UUID()

    // Custom plan
    @State private var customDays: [CustomStudyDay] = CustomStudyDay.load()
    @State private var selectedCustomDay: CustomStudyDay?

    // Session (clock-in timer)
    @State private var allTasks: [StudyTask] = StudyTask.loadAll()
    @StateObject private var sessionManager = SessionManager()

    // Practice exams
    @State private var selectedPracticeSource: PracticeExamSource? = nil
    @StateObject private var practiceNavigator = WebViewNavigator()

    // Music (Pandora)
    @State private var musicLoadedURL: URL? = nil
    @StateObject private var musicNavigator = WebViewNavigator()

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(SidebarItem.allCases, id: \.self, selection: $selectedSidebar) { item in
                Label(item.rawValue, systemImage: item.icon)
            }
            .navigationTitle("APHuG Prep")
            .listStyle(.sidebar)
        } content: {
            switch selectedSidebar {
            case .studyPlan:
                StudyPlanView(studyDays: $studyDays, selectedDay: $selectedDay)
                    .id(refreshID)

            case .session:
                SessionView(manager: sessionManager, allTasks: allTasks)

            case .practiceExams:
                PracticeView(
                    selectedSource: $selectedPracticeSource,
                    navigator: practiceNavigator
                )

            case .cramMode:
                CramView()

            case .music:
                MusicView(navigator: musicNavigator, loadedURL: $musicLoadedURL)

            case .resources:
                ResourcesView()

            case .textbook:
                TextbookView()

            case nil:
                Text("Select an item from the sidebar")
                    .foregroundStyle(.secondary)
            }
        } detail: {
            switch selectedSidebar {

            case .studyPlan:
                if let day = selectedDay {
                    DayDetailView(day: day) { isCompleted in
                        if let index = studyDays.firstIndex(where: { $0.id == day.id }) {
                            studyDays[index].isCompleted = isCompleted
                        }
                        refreshID = UUID()
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "hand.point.left.fill")
                            .font(.largeTitle).foregroundStyle(.secondary)
                        Text("Select a study day to get started")
                            .font(.title3).foregroundStyle(.secondary)
                    }
                }

            case .session:
                SessionDetailView(manager: sessionManager)

            case .practiceExams:
                if let source = selectedPracticeSource {
                    WebBrowserPane(
                        title: source.name,
                        subtitle: source.attribution,
                        accentColor: source.color,
                        homeURL: source.url,
                        navigator: practiceNavigator
                    )
                } else {
                    PracticeWelcomeView { source in
                        selectedPracticeSource = source
                        practiceNavigator.load(source.url)
                    }
                }

            case .music:
                if musicLoadedURL != nil {
                    WebBrowserPane(
                        title: "Pandora",
                        subtitle: "pandora.com",
                        accentColor: .pink,
                        homeURL: musicLoadedURL ?? URL(string: "https://www.pandora.com/")!,
                        navigator: musicNavigator
                    )
                } else {
                    MusicWelcomeView {
                        let home = URL(string: "https://www.pandora.com/")!
                        musicLoadedURL = home
                        musicNavigator.load(home)
                    }
                }

            default:
                EmptyView()
            }
        }
        .frame(minWidth: 1000, minHeight: 640)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showOnboarding = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .help("Open walkthrough & tips")
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
    }
}

#Preview {
    ContentView()
}
