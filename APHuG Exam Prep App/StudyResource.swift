//
//  StudyResource.swift
//  APHuG Exam Prep App
//
//  Created by apmckelvey on 4/14/26.
//

import Foundation

struct StudyResource: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let url: URL
    let category: ResourceCategory

    enum ResourceCategory: String, CaseIterable {
        case collegeboard = "College Board (Official)"
        case practice = "Practice & Review"
        case youtube = "Video Resources"
        case unit1 = "Unit 1 · Thinking Geographically"
        case unit2 = "Unit 2 · Population & Migration"
        case unit3 = "Unit 3 · Cultural Patterns & Processes"
        case unit4 = "Unit 4 · Political Patterns & Processes"
        case unit5 = "Unit 5 · Agriculture & Rural Land Use"
        case unit6 = "Unit 6 · Cities & Urban Land Use"
        case unit7 = "Unit 7 · Industrial & Economic Development"

        var icon: String {
            switch self {
            case .collegeboard: return "building.columns.fill"
            case .practice: return "checkmark.square.fill"
            case .youtube: return "play.rectangle.fill"
            case .unit1: return "map.fill"
            case .unit2: return "person.3.fill"
            case .unit3: return "globe.americas.fill"
            case .unit4: return "flag.fill"
            case .unit5: return "leaf.fill"
            case .unit6: return "building.2.fill"
            case .unit7: return "gearshape.2.fill"
            }
        }
    }
}

extension StudyResource {
    /// All curated study resources for AP Human Geography.
    static let all: [StudyResource] = [

        // MARK: - College Board Official

        StudyResource(
            title: "AP Human Geography — Course & Exam",
            description: "Official College Board course overview, exam format, scoring, and registration.",
            url: URL(string: "https://apstudents.collegeboard.org/courses/ap-human-geography")!,
            category: .collegeboard
        ),
        StudyResource(
            title: "AP Human Geography Course and Exam Description (CED)",
            description: "Complete official CED PDF with all learning objectives, key vocabulary, and sample questions.",
            url: URL(string: "https://apcentral.collegeboard.org/media/pdf/ap-human-geography-course-and-exam-description.pdf")!,
            category: .collegeboard
        ),
        StudyResource(
            title: "AP Classroom",
            description: "Official AP Classroom with AP Daily videos, progress checks, and practice questions for every unit.",
            url: URL(string: "https://myap.collegeboard.org/")!,
            category: .collegeboard
        ),
        StudyResource(
            title: "Past AP Exam Free-Response Questions",
            description: "All released FRQ prompts and scoring guidelines from previous AP Human Geography exams.",
            url: URL(string: "https://apcentral.collegeboard.org/courses/ap-human-geography/exam/past-exam-questions")!,
            category: .collegeboard
        ),
        StudyResource(
            title: "2026 AP Exam Schedule",
            description: "Official exam dates and administration info for the 2026 AP testing window.",
            url: URL(string: "https://apstudents.collegeboard.org/exam-calendar")!,
            category: .collegeboard
        ),
        StudyResource(
            title: "AP Score Reporting & Calculator",
            description: "How scores are weighted and what scores are needed for college credit.",
            url: URL(string: "https://apstudents.collegeboard.org/getting-credit-placement/search-policies")!,
            category: .collegeboard
        ),

        // MARK: - Practice & Review

        StudyResource(
            title: "Albert.io — AP Human Geography",
            description: "Thousands of practice MC questions organized by unit, with detailed explanations.",
            url: URL(string: "https://www.albert.io/ap-human-geography")!,
            category: .practice
        ),
        StudyResource(
            title: "Save My Exams — AP Human Geography",
            description: "Concise revision notes, practice questions, and mark schemes for every topic.",
            url: URL(string: "https://www.savemyexams.com/ap/human-geography/")!,
            category: .practice
        ),
        StudyResource(
            title: "PrepScholar — AP Human Geography Guide",
            description: "Study guides, key terms, and full-length practice tests with score analysis.",
            url: URL(string: "https://www.prepscholar.com/act/s/ap-human-geography")!,
            category: .practice
        ),
        StudyResource(
            title: "Quizlet — AP Human Geography",
            description: "Community flashcard sets for every unit and key vocabulary term.",
            url: URL(string: "https://quizlet.com/subject/ap-human-geography/")!,
            category: .practice
        ),
        StudyResource(
            title: "Khan Academy — AP Human Geography",
            description: "Free lessons and exercises aligned to the AP Human Geography curriculum.",
            url: URL(string: "https://www.khanacademy.org/humanities/ap-human-geography")!,
            category: .practice
        ),

        // MARK: - Video Resources

        StudyResource(
            title: "Heimler's History — AP Human Geography Playlist",
            description: "Concise, unit-by-unit video reviews covering every key concept tested on the exam.",
            url: URL(string: "https://www.youtube.com/playlist?list=PLiswPBuJdN-d-1hzA_nJv4_QF-JNIhxNQ")!,
            category: .youtube
        ),
        StudyResource(
            title: "Tom Richey — AP Human Geography",
            description: "In-depth content reviews, FRQ walkthroughs, and exam strategy from an AP veteran teacher.",
            url: URL(string: "https://www.youtube.com/@TomRichey")!,
            category: .youtube
        ),
        StudyResource(
            title: "Marks Education — AP Human Geography",
            description: "Focused content videos and FRQ tips from an experienced AP tutor.",
            url: URL(string: "https://www.youtube.com/@MarksEducation")!,
            category: .youtube
        ),

        // MARK: - Unit 1

        StudyResource(
            title: "AP Classroom · Unit 1 Progress Check",
            description: "Official practice questions on map types, scale, spatial concepts, regions, and GIS.",
            url: URL(string: "https://myap.collegeboard.org/")!,
            category: .unit1
        ),
        StudyResource(
            title: "Albert.io · Unit 1 Practice",
            description: "Unit 1 targeted MC questions covering projections, map types, and geographic thinking.",
            url: URL(string: "https://www.albert.io/ap-human-geography/unit-1")!,
            category: .unit1
        ),
        StudyResource(
            title: "Heimler's History · Unit 1 Review",
            description: "Fast video review of scale, map projections, regions, and GIS/remote sensing.",
            url: URL(string: "https://www.youtube.com/watch?v=M5eJZ7a3a5g")!,
            category: .unit1
        ),

        // MARK: - Unit 2

        StudyResource(
            title: "AP Classroom · Unit 2 Progress Check",
            description: "Official questions on the DTM, population pyramids, density, migration, and Malthus.",
            url: URL(string: "https://myap.collegeboard.org/")!,
            category: .unit2
        ),
        StudyResource(
            title: "Albert.io · Unit 2 Practice",
            description: "MC practice on population patterns, demographic transition, and migration theory.",
            url: URL(string: "https://www.albert.io/ap-human-geography/unit-2")!,
            category: .unit2
        ),
        StudyResource(
            title: "Population Reference Bureau",
            description: "Real-world data and infographics on global population, fertility, and migration.",
            url: URL(string: "https://www.prb.org/")!,
            category: .unit2
        ),

        // MARK: - Unit 3

        StudyResource(
            title: "AP Classroom · Unit 3 Progress Check",
            description: "Official questions on cultural landscapes, folk/pop culture, language, religion, and diffusion.",
            url: URL(string: "https://myap.collegeboard.org/")!,
            category: .unit3
        ),
        StudyResource(
            title: "Albert.io · Unit 3 Practice",
            description: "Practice questions on diffusion types, cultural barriers, and cultural landscapes.",
            url: URL(string: "https://www.albert.io/ap-human-geography/unit-3")!,
            category: .unit3
        ),

        // MARK: - Unit 4

        StudyResource(
            title: "AP Classroom · Unit 4 Progress Check",
            description: "Official questions on state/nation concepts, boundaries, devolution, and supranational orgs.",
            url: URL(string: "https://myap.collegeboard.org/")!,
            category: .unit4
        ),
        StudyResource(
            title: "Albert.io · Unit 4 Practice",
            description: "Practice on geopolitical theory, boundary types, and political organization.",
            url: URL(string: "https://www.albert.io/ap-human-geography/unit-4")!,
            category: .unit4
        ),
        StudyResource(
            title: "CIA World Factbook",
            description: "Authoritative data on every country's government, geography, economy, and demographics.",
            url: URL(string: "https://www.cia.gov/the-world-factbook/")!,
            category: .unit4
        ),

        // MARK: - Unit 5

        StudyResource(
            title: "AP Classroom · Unit 5 Progress Check",
            description: "Official questions on agricultural types, Green Revolution, land tenure, and von Thünen.",
            url: URL(string: "https://myap.collegeboard.org/")!,
            category: .unit5
        ),
        StudyResource(
            title: "Albert.io · Unit 5 Practice",
            description: "Agriculture MC covering subsistence, commercial, GMOs, and sustainability.",
            url: URL(string: "https://www.albert.io/ap-human-geography/unit-5")!,
            category: .unit5
        ),
        StudyResource(
            title: "USDA Economic Research Service",
            description: "Data and reports on global agricultural production, trade, and food security.",
            url: URL(string: "https://www.ers.usda.gov/")!,
            category: .unit5
        ),

        // MARK: - Unit 6

        StudyResource(
            title: "AP Classroom · Unit 6 Progress Check",
            description: "Official questions on urban models, gentrification, smart growth, and urban hierarchies.",
            url: URL(string: "https://myap.collegeboard.org/")!,
            category: .unit6
        ),
        StudyResource(
            title: "Albert.io · Unit 6 Practice",
            description: "Urban geography MC covering rank-size, primate cities, Burgess/Hoyt/Multiple Nuclei.",
            url: URL(string: "https://www.albert.io/ap-human-geography/unit-6")!,
            category: .unit6
        ),

        // MARK: - Unit 7

        StudyResource(
            title: "AP Classroom · Unit 7 Progress Check",
            description: "Official questions on Rostow, HDI, core-periphery, EPZs, and deindustrialization.",
            url: URL(string: "https://myap.collegeboard.org/")!,
            category: .unit7
        ),
        StudyResource(
            title: "Albert.io · Unit 7 Practice",
            description: "Development and industry MC: sectors, NICs, globalization, and inequality.",
            url: URL(string: "https://www.albert.io/ap-human-geography/unit-7")!,
            category: .unit7
        ),
        StudyResource(
            title: "World Bank Open Data",
            description: "GDP, GNI, HDI, and development indicator data for every country.",
            url: URL(string: "https://data.worldbank.org/")!,
            category: .unit7
        ),
        StudyResource(
            title: "UNDP Human Development Reports",
            description: "Official HDI rankings and reports published annually by the United Nations.",
            url: URL(string: "https://hdr.undp.org/")!,
            category: .unit7
        )
    ]

    /// Returns resources filtered to a specific category.
    static func resources(for category: StudyResource.ResourceCategory) -> [StudyResource] {
        all.filter { $0.category == category }
    }

    /// Returns unit-specific resources relevant to the given unit focus string (e.g. "Unit 4").
    static func unitResources(for unitFocus: String) -> [StudyResource] {
        let unitCategories: [String: StudyResource.ResourceCategory] = [
            "Unit 1": .unit1,
            "Unit 2": .unit2,
            "Unit 3": .unit3,
            "Unit 4": .unit4,
            "Unit 5": .unit5,
            "Unit 6": .unit6,
            "Unit 7": .unit7
        ]
        // Support multi-unit days like "Units 1 & 7"
        var results: [StudyResource] = []
        for (key, category) in unitCategories {
            if unitFocus.contains(key) {
                results.append(contentsOf: resources(for: category))
            }
        }
        // For "All units" days, return official CB + practice resources
        if unitFocus == "All units" {
            results = resources(for: .collegeboard) + resources(for: .practice)
        }
        return results
    }
}
