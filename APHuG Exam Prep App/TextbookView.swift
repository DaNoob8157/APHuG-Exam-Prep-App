//
//  TextbookView.swift
//  APHuG Exam Prep App
//
//  Created by apmckelvey on 4/14/26.
//

import SwiftUI
import PDFKit

struct TextbookView: View {
    @State private var currentPage: Int = 0
    @State private var totalPages: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            if let url = Bundle.main.url(forResource: "AP Human Gepgraphy", withExtension: "pdf") {
                PDFKitView(url: url, currentPage: $currentPage, totalPages: $totalPages)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom page info bar
                HStack {
                    Text("AP Human Geography Textbook")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if totalPages > 0 {
                        Text("Page \(currentPage + 1) of \(totalPages)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(.bar)
            } else {
                ContentUnavailableView(
                    "Textbook Not Found",
                    systemImage: "book.closed",
                    description: Text("The PDF textbook could not be loaded. Make sure \"AP Human Gepgraphy.pdf\" is included in the app bundle.")
                )
            }
        }
    }
}

struct PDFKitView: NSViewRepresentable {
    let url: URL
    @Binding var currentPage: Int
    @Binding var totalPages: Int

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical

        if let document = PDFDocument(url: url) {
            pdfView.document = document
            DispatchQueue.main.async {
                totalPages = document.pageCount
            }
        }

        // Observe page changes
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: .PDFViewPageChanged,
            object: pdfView
        )

        return pdfView
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        // No dynamic updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(currentPage: $currentPage)
    }

    class Coordinator: NSObject {
        @Binding var currentPage: Int

        init(currentPage: Binding<Int>) {
            _currentPage = currentPage
        }

        @objc func pageChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView,
                  let currentPDFPage = pdfView.currentPage,
                  let document = pdfView.document else { return }
            let pageIndex = document.index(for: currentPDFPage)
            DispatchQueue.main.async {
                self.currentPage = pageIndex
            }
        }
    }
}
