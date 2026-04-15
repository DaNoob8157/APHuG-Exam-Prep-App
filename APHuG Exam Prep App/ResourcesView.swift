//
//  ResourcesView.swift
//  APHuG Exam Prep App
//
//  Created by apmckelvey on 4/14/26.
//

import SwiftUI

struct ResourcesView: View {
    @State private var searchText = ""
    @State private var selectedCategory: StudyResource.ResourceCategory? = nil

    var filteredResources: [StudyResource] {
        var list = StudyResource.all
        if let cat = selectedCategory {
            list = list.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            list = list.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        return list
    }

    var groupedResources: [(StudyResource.ResourceCategory, [StudyResource])] {
        let grouped = Dictionary(grouping: filteredResources, by: \.category)
        return StudyResource.ResourceCategory.allCases
            .compactMap { cat in
                guard let items = grouped[cat], !items.isEmpty else { return nil }
                return (cat, items)
            }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search resources…", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(.thinMaterial)

            Divider()

            // Category filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(label: "All", icon: "square.grid.2x2.fill", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    ForEach(StudyResource.ResourceCategory.allCases, id: \.self) { cat in
                        FilterChip(label: cat.rawValue, icon: cat.icon, isSelected: selectedCategory == cat) {
                            selectedCategory = selectedCategory == cat ? nil : cat
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .background(.ultraThinMaterial)

            Divider()

            // Resource list grouped by category
            if groupedResources.isEmpty {
                Spacer()
                ContentUnavailableView(
                    "No Resources Found",
                    systemImage: "magnifyingglass",
                    description: Text("Try a different search or category filter.")
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                        ForEach(groupedResources, id: \.0) { category, resources in
                            Section {
                                ForEach(resources) { resource in
                                    ResourceRow(resource: resource)
                                    if resource.id != resources.last?.id {
                                        Divider().padding(.leading, 48)
                                    }
                                }
                                .background()
                            } header: {
                                CategoryHeader(category: category)
                            }
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct CategoryHeader: View {
    let category: StudyResource.ResourceCategory

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: category.icon)
                .foregroundStyle(.white)
                .font(.caption.weight(.semibold))
                .frame(width: 22, height: 22)
                .background(categoryColor.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            Text(category.rawValue)
                .font(.subheadline.weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.bar)
    }

    var categoryColor: Color {
        switch category {
        case .collegeboard: return .blue
        case .practice: return .orange
        case .youtube: return .red
        case .unit1: return .blue
        case .unit2: return .orange
        case .unit3: return .purple
        case .unit4: return .red
        case .unit5: return .brown
        case .unit6: return .teal
        case .unit7: return .indigo
        }
    }
}

struct ResourceRow: View {
    let resource: StudyResource
    @State private var isHovered = false

    var body: some View {
        Link(destination: resource.url) {
            HStack(spacing: 12) {
                Image(systemName: "link.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.title3)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 3) {
                    Text(resource.title)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(resource.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Text(resource.url.host ?? resource.url.absoluteString)
                        .font(.caption2)
                        .foregroundStyle(.blue.opacity(0.8))
                }

                Spacer()

                Image(systemName: "arrow.up.right.square")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .opacity(isHovered ? 1 : 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isHovered ? Color.accentColor.opacity(0.06) : .clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct FilterChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.12))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ResourcesView()
        .frame(width: 600, height: 700)
}
