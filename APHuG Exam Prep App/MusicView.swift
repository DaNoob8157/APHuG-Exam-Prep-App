//
//  MusicView.swift
//  APHuG Exam Prep App
//
//  Pandora integration — embedded browser with study-station quick-links.
//

import SwiftUI

// MARK: - Station data

struct StudyStation: Identifiable {
    let id = UUID()
    let name: String
    let genre: String
    let icon: String
    let color: Color
    let searchURL: URL
}

private let studyStations: [StudyStation] = [
    StudyStation(name: "Lo-Fi Hip Hop",      genre: "Focus beats",     icon: "headphones",           color: .indigo,
                 searchURL: URL(string: "https://www.pandora.com/search/lo%20fi%20hip%20hop/stations")!),
    StudyStation(name: "Classical Piano",    genre: "Concentration",   icon: "pianokeys",             color: .blue,
                 searchURL: URL(string: "https://www.pandora.com/search/classical%20piano/stations")!),
    StudyStation(name: "Ambient Focus",      genre: "Deep work",       icon: "waveform",              color: .teal,
                 searchURL: URL(string: "https://www.pandora.com/search/ambient%20focus/stations")!),
    StudyStation(name: "Acoustic Study",     genre: "Calm & quiet",    icon: "guitars",               color: .brown,
                 searchURL: URL(string: "https://www.pandora.com/search/acoustic%20study/stations")!),
    StudyStation(name: "Jazz Café",          genre: "Background jazz", icon: "music.quarternote.3",   color: .orange,
                 searchURL: URL(string: "https://www.pandora.com/search/jazz%20cafe/stations")!),
    StudyStation(name: "Cinematic Scores",   genre: "Epic focus",      icon: "film.fill",             color: .purple,
                 searchURL: URL(string: "https://www.pandora.com/search/cinematic%20study/stations")!),
    StudyStation(name: "Nature Sounds",      genre: "Rain & white noise", icon: "cloud.rain.fill",    color: .cyan,
                 searchURL: URL(string: "https://www.pandora.com/search/nature%20sounds/stations")!),
    StudyStation(name: "Video Game OSTs",    genre: "Game soundtracks", icon: "gamecontroller.fill",  color: .green,
                 searchURL: URL(string: "https://www.pandora.com/search/video%20game%20music/stations")!),
]

// MARK: - Content pane

struct MusicView: View {
    @ObservedObject var navigator: WebViewNavigator
    @Binding var loadedURL: URL?

    private let pandoraHome = URL(string: "https://www.pandora.com/")!

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "music.note")
                        .foregroundStyle(.pink)
                    Text("Pandora")
                        .font(.headline)
                }
                Text("Pick a study station or browse Pandora below.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            // Station list
            List {
                Section("Study Stations") {
                    ForEach(studyStations) { station in
                        StationRow(station: station) {
                            loadedURL = station.searchURL
                            navigator.load(station.searchURL)
                        }
                    }
                }

                Section {
                    Button {
                        loadedURL = pandoraHome
                        navigator.load(pandoraHome)
                    } label: {
                        Label("Open Pandora Home", systemImage: "globe")
                            .font(.body)
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Browse")
                }
            }
            .listStyle(.sidebar)
        }
    }
}

// MARK: - Station row

struct StationRow: View {
    let station: StudyStation
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: station.icon)
                    .foregroundStyle(.white)
                    .font(.body)
                    .frame(width: 34, height: 34)
                    .background(station.color.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(station.name)
                        .font(.body.weight(.medium))
                    Text(station.genre)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Welcome panel (detail pane before any station is chosen)

struct MusicWelcomeView: View {
    let onBrowse: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "music.note.house.fill")
                .font(.system(size: 72))
                .foregroundStyle(.pink)

            VStack(spacing: 8) {
                Text("Study Music")
                    .font(.largeTitle.bold())
                Text("Pick a station from the list to open Pandora in the built-in browser.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Text("💡 Tip: Lo-Fi, Classical, and Ambient are great for memorising AP concepts.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)

            Button {
                NSWorkspace.shared.open(URL(string: "https://www.pandora.com/")!)
            } label: {
                Label("Open Pandora in Browser", systemImage: "arrow.up.right.square")
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
