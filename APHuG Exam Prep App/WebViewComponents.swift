//
//  WebViewComponents.swift
//  APHuG Exam Prep App
//
//  Shared WKWebView wrapper used by PracticeView and MusicView.
//

import SwiftUI
import WebKit

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

                Button {
                    NSWorkspace.shared.open(navigator.currentURL ?? homeURL)
                } label: {
                    Label("Open in Browser", systemImage: "arrow.up.right.square")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .help("Open in default browser")
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
                    Text("Check your internet connection, or open in Safari.")
                        .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    HStack(spacing: 12) {
                        Button("Try Again") { navigator.reload() }.buttonStyle(.bordered)
                        Button("Open in Browser") {
                            NSWorkspace.shared.open(homeURL)
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
