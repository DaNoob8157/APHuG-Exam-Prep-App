//
//  WebViewComponents.swift
//  APHuG Exam Prep App
//
//  Shared WKWebView wrapper used by PracticeView and MusicView.
//

import SwiftUI
import WebKit
import Combine
import AppKit

// MARK: - Chrome helper

/// Opens `url` in Google Chrome. Falls back to the system default browser if Chrome is not installed.
func openInChrome(_ url: URL) {
    if let chromeURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") {
        let cfg = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.open([url], withApplicationAt: chromeURL, configuration: cfg)
    } else {
        NSWorkspace.shared.open(url)
    }
}

// MARK: - Navigator (shared state)

final class WebViewNavigator: NSObject, ObservableObject, WKNavigationDelegate {
    @Published var canGoBack    = false
    @Published var canGoForward = false
    @Published var isLoading    = false
    @Published var hasError     = false
    @Published var currentURL: URL?

    weak var webView: WKWebView?

    func load(_ url: URL) {
        hasError = false
        webView?.load(URLRequest(url: url))
    }
    func goBack()    { webView?.goBack() }
    func goForward() { webView?.goForward() }
    func reload()    { webView?.reload() }

    // MARK: WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        isLoading = true
        hasError  = false
        self.webView = webView
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        isLoading   = false
        canGoBack   = webView.canGoBack
        canGoForward = webView.canGoForward
        currentURL  = webView.url
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
        isLoading = false
        hasError  = true
    }

    func webView(_ webView: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        isLoading = false
        hasError  = true
    }
}

// MARK: - NSViewRepresentable

struct APHuGWebView: NSViewRepresentable {
    let url: URL
    @ObservedObject var navigator: WebViewNavigator

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = navigator
        navigator.webView = webView
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        guard let current = nsView.url, current.absoluteString != url.absoluteString,
              !navigator.isLoading else { return }
        navigator.hasError = false
        nsView.load(URLRequest(url: url))
    }
}

// MARK: - Browser toolbar + pane (reusable)

struct WebBrowserPane: View {
    let title: String
    let subtitle: String
    let accentColor: Color
    let homeURL: URL
    @ObservedObject var navigator: WebViewNavigator
    @State private var showTip = false

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 8) {
                Button { navigator.goBack()    } label: { Image(systemName: "chevron.left")  }
                    .disabled(!navigator.canGoBack).buttonStyle(.plain).help("Back")
                Button { navigator.goForward() } label: { Image(systemName: "chevron.right") }
                    .disabled(!navigator.canGoForward).buttonStyle(.plain).help("Forward")
                Button { navigator.reload()    } label: {
                    Image(systemName: navigator.isLoading ? "xmark" : "arrow.clockwise")
                }
                .buttonStyle(.plain).help(navigator.isLoading ? "Stop" : "Reload")

                Divider().frame(height: 16)

                Text(title)
                    .font(.caption.weight(.semibold))
                if !subtitle.isEmpty {
                    Text("·").foregroundStyle(.secondary)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Tip popover button
                Button {
                    showTip.toggle()
                } label: {
                    Image(systemName: "lightbulb")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help("Browser tips")
                .popover(isPresented: $showTip, arrowEdge: .bottom) {
                    TipPopover(
                        title: "Browser Tips",
                        tips: [
                            (icon: "arrow.left.and.right.square",
                             text: "Drag the divider on the left edge of this panel to make the browser wider or narrower."),
                            (icon: "arrow.up.backward.and.arrow.down.forward.square",
                             text: "Press ⌃⌘F or click the green traffic-light button to go full-screen."),
                            (icon: "arrow.clockwise",
                             text: "Tap ↻ if a page gets stuck loading."),
                            (icon: "arrow.up.right.square",
                             text: "Tap \"Open in Chrome\" to view the site in Google Chrome in a larger window."),
                            (icon: "hand.pinch",
                             text: "Use trackpad pinch-to-zoom inside the web view to adjust text size."),
                        ],
                        isPresented: $showTip
                    )
                }

                Button {
                    openInChrome(navigator.currentURL ?? homeURL)
                } label: {
                    Label("Open in Chrome", systemImage: "arrow.up.right.square")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .help("Open in Google Chrome")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.bar)

            if navigator.isLoading {
                ProgressView().progressViewStyle(.linear).frame(height: 2)
            } else {
                Divider()
            }

            if navigator.hasError {
                VStack(spacing: 16) {
                    Image(systemName: "wifi.slash").font(.system(size: 48)).foregroundStyle(.secondary)
                    Text("Can't load this page").font(.headline)
                    Text("Check your internet connection, or open in Chrome.")
                        .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    HStack(spacing: 12) {
                        Button("Try Again") { navigator.reload() }.buttonStyle(.bordered)
                        Button("Open in Chrome") {
                            openInChrome(homeURL)
                        }.buttonStyle(.borderedProminent).tint(accentColor)
                    }
                }
                .padding(40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                APHuGWebView(url: homeURL, navigator: navigator)
            }
        }
    }
}
