//
//  StudyDay.swift
//  APHuG Exam Prep App
//
//  Created by apmckelvey on 4/14/26.
//

import Foundation

struct StudyDay: Identifiable {
    let id: Int
    let day: Int
    let unitFocus: String
    let contentFocus: String
    let practiceMC: String
    let frqWork: String

    var isCompleted: Bool {
        get {
            UserDefaults.standard.bool(forKey: "day_\(day)_completed")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "day_\(day)_completed")
        }
    }
}

extension StudyDay {
    /// Parses the bundled CSV and returns all study days.
    static func loadFromCSV() -> [StudyDay] {
        guard let url = Bundle.main.url(forResource: "StudyPlan", withExtension: "csv"),
              let contents = try? String(contentsOf: url, encoding: .utf8) else {
            // Fallback to embedded data if CSV can't be loaded
            return Self.embeddedData
        }

        var days: [StudyDay] = []
        let lines = contents.components(separatedBy: .newlines).filter { !$0.isEmpty }

        // Skip header row
        for (index, line) in lines.dropFirst().enumerated() {
            let fields = parseCSVLine(line)
            guard fields.count >= 5 else { continue }

            let day = StudyDay(
                id: index,
                day: Int(fields[0].trimmingCharacters(in: .whitespaces)) ?? (index + 1),
                unitFocus: fields[1].trimmingCharacters(in: .whitespaces),
                contentFocus: fields[2].trimmingCharacters(in: .whitespaces),
                practiceMC: fields[3].trimmingCharacters(in: .whitespaces),
                frqWork: fields[4].trimmingCharacters(in: .whitespaces)
            )
            days.append(day)
        }

        return days.isEmpty ? Self.embeddedData : days
    }

    /// Simple CSV line parser that handles quoted fields.
    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false

        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                fields.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        fields.append(current)
        return fields
    }

    /// Hardcoded fallback data from the CSV in case bundle resource loading fails.
    static let embeddedData: [StudyDay] = [
        StudyDay(id: 0, day: 1, unitFocus: "Unit 7",
                 contentFocus: "Sectors (primary–quinary), HDI/GNI, Rostow, core–periphery, NICs.",
                 practiceMC: "10–15 dev/industry questions.",
                 frqWork: "3–4 sentences on HDI calculation + one limitation."),
        StudyDay(id: 1, day: 2, unitFocus: "Unit 7",
                 contentFocus: "Globalization, outsourcing, EPZs/SEZs, offshoring, inequality, deindustrialization.",
                 practiceMC: "10–15 Unit 7 questions (graphs/maps).",
                 frqWork: "Outline prompt on outsourcing's effects on core vs periphery."),
        StudyDay(id: 2, day: 3, unitFocus: "Unit 6",
                 contentFocus: "Urbanization, rank‑size vs primate, Burgess, Hoyt, Multiple Nuclei models.",
                 practiceMC: "10–15 questions on urban models.",
                 frqWork: "Sketch 3 models + 1 example city each."),
        StudyDay(id: 3, day: 4, unitFocus: "Unit 6",
                 contentFocus: "Suburbanization, sprawl, gentrification, redlining, smart growth, sustainability.",
                 practiceMC: "10–15 urban issues questions.",
                 frqWork: "Bullets on causes & consequences of gentrification."),
        StudyDay(id: 4, day: 5, unitFocus: "Unit 5",
                 contentFocus: "Commercial vs subsistence, intensive vs extensive, major agriculture types.",
                 practiceMC: "10–15 agriculture questions.",
                 frqWork: "Draw von Thünen, label rings, 2 sentences on tech effects."),
        StudyDay(id: 5, day: 6, unitFocus: "Unit 5",
                 contentFocus: "Green Revolution, GMOs, mechanization, land tenure, environmental/social impacts.",
                 practiceMC: "10–15 Green Revolution/food questions.",
                 frqWork: "3–4 sentences: effects in core vs periphery country."),
        StudyDay(id: 6, day: 7, unitFocus: "Unit 4",
                 contentFocus: "State, nation, nation‑state, stateless, multinational/multi‑state; colonialism/imperialism.",
                 practiceMC: "10–15 political vocab questions.",
                 frqWork: "Table of examples for each (state, nation, etc.)."),
        StudyDay(id: 7, day: 8, unitFocus: "Unit 4",
                 contentFocus: "Boundary types/disputes, unitary vs federal, devolution, supranational orgs.",
                 practiceMC: "10–15 boundary/supranational questions.",
                 frqWork: "Outline: how EU‑type org affects sovereignty."),
        StudyDay(id: 8, day: 9, unitFocus: "Unit 3",
                 contentFocus: "Culture, cultural landscape, folk vs popular culture, diffusion types.",
                 practiceMC: "10–15 culture/diffusion questions.",
                 frqWork: "Diagram linking each diffusion type to 1 real example."),
        StudyDay(id: 9, day: 10, unitFocus: "Unit 2",
                 contentFocus: "Densities, DTM stages, pyramids, dependency, Malthus/Neo‑Malthus.",
                 practiceMC: "10–15 population/pyramid questions.",
                 frqWork: "Bullets: country evolving from stage 2 → 3 → 4."),
        StudyDay(id: 10, day: 11, unitFocus: "Unit 2",
                 contentFocus: "Push–pull, forced vs voluntary, internal vs international, Ravenstein, refugees, remittances.",
                 practiceMC: "10–15 migration questions.",
                 frqWork: "3–4 sentences: migration's social & economic impacts on one region."),
        StudyDay(id: 11, day: 12, unitFocus: "Unit 1",
                 contentFocus: "Scale, projections, map types, regions, GIS/remote sensing.",
                 practiceMC: "10–15 Unit 1 map/scale questions.",
                 frqWork: "3–4 sentences defining & exemplifying region types."),
        StudyDay(id: 12, day: 13, unitFocus: "All units",
                 contentFocus: "Quick scan of notes for Units 7→1; general tips/strategy.",
                 practiceMC: "20 mixed questions, timed (~45 sec each).",
                 frqWork: "One full FRQ question under 10 minutes (focus structure & key terms)."),
        StudyDay(id: 13, day: 14, unitFocus: "Units 1 & 7",
                 contentFocus: "15 min Unit 1 high‑yield; 15 min Unit 7 high‑yield.",
                 practiceMC: "10–12 Unit 1 & 7 questions only.",
                 frqWork: "Outline FRQ connecting development to a spatial pattern (e.g., urbanization).")
    ]
}
