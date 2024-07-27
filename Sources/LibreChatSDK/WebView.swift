#if canImport(WebKit)
import SwiftUI
import WebKit

#if canImport(UIKit)
public struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var loading: Bool
    let refreshToken: (String) -> Void

    public init(url: URL, loading: Binding<Bool>, refreshToken: @escaping (String) -> Void) {
        self.url = url
        self._loading = loading
        self.refreshToken = refreshToken
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self, $loading, refreshToken)
    }

    public func makeUIView(context: Context) -> WKWebView  {
        let configuartion = WKWebViewConfiguration()
//        configuartion.websiteDataStore = .nonPersistent()

        let userScript = WKUserScript(source: getScript(), injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuartion.userContentController.addUserScript(userScript)
        configuartion.userContentController.add(context.coordinator, name: "handler")

        let wkwebView = WKWebView(frame: .zero, configuration: configuartion)

        wkwebView.navigationDelegate = context.coordinator
        wkwebView.uiDelegate = context.coordinator

        context.coordinator.webView = wkwebView

        let request = URLRequest(url: url)
        loading = true
        wkwebView.load(request)
        return wkwebView
    }

    private func getScript() -> String {
        """
var open = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function() {
    this.addEventListener("load", function() {
        var message = {"status" : this.status, "responseURL" : this.responseURL}
        webkit.messageHandlers.handler.postMessage(message);
    });
    open.apply(this, arguments);
};
"""
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {}

    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        let parent: WebView
        let loading: Binding<Bool>
        let refreshToken: (String) -> Void

        weak var webView: WKWebView?
        private var waitForTokenStream: AsyncStream<Void>?
        private var waitForTokenContinuation: AsyncStream<Void>.Continuation?

        init(_ parent: WebView, _ loading: Binding<Bool>, _ refreshToken: @escaping (String) -> Void) {
            self.parent = parent
            self.loading = loading
            self.refreshToken = refreshToken
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            loading.wrappedValue = false
        }

        private func readToken(store: WKHTTPCookieStore) async -> String? {
            guard let refreshToken = await store.allCookies().first(where: { $0.name == "refreshToken" }) else { return nil }
            return refreshToken.value
        }

        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let dict = message.body as? Dictionary<String, AnyObject>, let status = dict["status"] as? Int, let responseUrl = dict["responseURL"] as? String else { return }
            guard responseUrl.contains("api/user") && status == 200 else { return }
            guard let webView else { return }
            Task { @MainActor in
                guard let token = await readToken(store: webView.configuration.websiteDataStore.httpCookieStore) else { return }
                self.refreshToken(token)
            }
        }
    }
}
#elseif canImport(AppKit)
public struct WebView: NSViewRepresentable {
    let url: URL
    @Binding var loading: Bool
    let refreshToken: (String) -> Void

    public init(url: URL, loading: Binding<Bool>, refreshToken: @escaping (String) -> Void) {
        self.url = url
        self._loading = loading
        self.refreshToken = refreshToken
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self, $loading, refreshToken)
    }

    public func makeNSView(context: Context) -> WKWebView  {
        var configuartion = WKWebViewConfiguration()
//        configuartion.websiteDataStore = .nonPersistent()

        let userScript = WKUserScript(source: getScript(), injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuartion.userContentController.addUserScript(userScript)
        configuartion.userContentController.add(context.coordinator, name: "handler")

        let wkwebView = WKWebView(frame: .zero, configuration: configuartion)

        wkwebView.navigationDelegate = context.coordinator
        wkwebView.uiDelegate = context.coordinator

        context.coordinator.webView = wkwebView

        let request = URLRequest(url: url)
        loading = true
        wkwebView.load(request)
        return wkwebView
    }

    private func getScript() -> String {
        """
var open = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function() {
    this.addEventListener("load", function() {
        var message = {"status" : this.status, "responseURL" : this.responseURL}
        webkit.messageHandlers.handler.postMessage(message);
    });
    open.apply(this, arguments);
};
"""
    }

    public func updateNSView(_ view: WKWebView, context: Context) {}

    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        let parent: WebView
        let loading: Binding<Bool>
        let refreshToken: (String) -> Void

        weak var webView: WKWebView?
        private var waitForTokenStream: AsyncStream<Void>?
        private var waitForTokenContinuation: AsyncStream<Void>.Continuation?

        init(_ parent: WebView, _ loading: Binding<Bool>, _ refreshToken: @escaping (String) -> Void) {
            self.parent = parent
            self.loading = loading
            self.refreshToken = refreshToken
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            loading.wrappedValue = false
        }

        private func readToken(store: WKHTTPCookieStore) async -> String? {
            guard let refreshToken = await store.allCookies().first(where: { $0.name == "refreshToken" }) else { return nil }
            return refreshToken.value
        }

        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let dict = message.body as? Dictionary<String, AnyObject>, let status = dict["status"] as? Int, let responseUrl = dict["responseURL"] as? String else { return }
            guard responseUrl.contains("api/user") && status == 200 else { return }
            guard let webView else { return }
            Task { @MainActor in
                guard let token = await readToken(store: webView.configuration.websiteDataStore.httpCookieStore) else { return }
                self.refreshToken(token)
            }
        }
    }
}
#endif
#endif
