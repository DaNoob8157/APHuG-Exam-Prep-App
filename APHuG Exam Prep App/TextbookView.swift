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
        if let url = Bundle.main.url(forResource: "AP Human Gepgraphy", withExtension: "pdf") {
            ZStack(alignment: .bottom) {
                PDFKitView(url: url, currentPage: $currentPage, totalPages: $totalPages)

                // Floating page indicator
                if totalPages > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text")
                            .font(.caption2)
                        Text("Page \(currentPage + 1) of \(totalPages)")
                            .font(.caption2.monospacedDigit())
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.thinMaterial, in: Capsule())
                    .padding(.bottom, 12)
                }
            }
            .ignoresSafeArea()
        } else {
            ContentUnavailableView(
                "Textbook Not Found",
                systemImage: "book.closed",
                description: Text("The PDF could not be loaded. Make sure \"AP Human Gepgraphy.pdf\" is included in the app bundle.")
            )
        }
    }
}

/// PDFView subclass that re-fits the page to the view bounds on every layout pass.
class AutoFitPDFView: PDFView {
    override func layout() {
        super.layout()
        guard document != nil else { return }
        scaleFactor = scaleFactorForSizeToFit
    }
}

struct PDFKitView: NSViewRepresentable {
    let url: URL
    @Binding var currentPage: Int
    @Binding var totalPages: Int

    func makeNSView(context: Context) -> AutoFitPDFView {
        let pdfView = AutoFitPDFView()
        // displayBox = .mediaBox ensures the full page area is used
        pdfView.displayBox = .mediaBox
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .vertical
        // autoScales is false so our AutoFitPDFView.layout() drives scaling
        pdfView.autoScales = false

        if let document = PDFDocument(url: url) {
            pdfView.document = document
            DispatchQueue.main.async {
                totalPages = document.pageCount
            }
        }

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: .PDFViewPageChanged,
            object: pdfView
        )

        return pdfView
    }

    func updateNSView(_ nsView: AutoFitPDFView, context: Context) {
        // Re-fit whenever SwiftUI lays us out
        nsView.scaleFactor = nsView.scaleFactorForSizeToFit
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
