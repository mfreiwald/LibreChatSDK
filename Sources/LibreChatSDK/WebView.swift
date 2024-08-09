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
        var configuartion = WKWebViewConfiguration()

        let namespaceUUID = UUID(uuidString: "6ba7b811-9dad-11d1-80b4-00c04fd430c8")! // Use a predefined namespace UUID
        let uuid = generateUUIDv5(namespaceUUID: namespaceUUID, name: url.absoluteString) ?? namespaceUUID
        logger.debug("URL: \(url.absoluteString)")
        logger.debug("UUID: \(uuid.uuidString)")
        configuartion.websiteDataStore = WKWebsiteDataStore(forIdentifier: uuid)

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

        let namespaceUUID = UUID(uuidString: "6ba7b811-9dad-11d1-80b4-00c04fd430c8")! // Use a predefined namespace UUID
        let uuid = generateUUIDv5(namespaceUUID: namespaceUUID, name: url.absoluteString) ?? namespaceUUID
        logger.debug("URL: \(url.absoluteString)")
        logger.debug("UUID: \(uuid.uuidString)")
        configuartion.websiteDataStore = WKWebsiteDataStore(forIdentifier: uuid)

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

import CryptoKit

func generateUUIDv5(namespaceUUID: UUID, name: String) -> UUID? {
    // Konvertiere die UUID des Namespace in Bytes.
    let namespaceUUIDBytes = namespaceUUID.uuid

    // Konvertiere den Namen in Data.
    guard let nameData = name.data(using: .utf8) else {
        return nil
    }

    // Verbinden von namespaceUUIDBytes und nameData.
    var data = Data()
    data.append(namespaceUUIDBytes.0)
    data.append(namespaceUUIDBytes.1)
    data.append(namespaceUUIDBytes.2)
    data.append(namespaceUUIDBytes.3)
    data.append(namespaceUUIDBytes.4)
    data.append(namespaceUUIDBytes.5)
    data.append(namespaceUUIDBytes.6)
    data.append(namespaceUUIDBytes.7)
    data.append(namespaceUUIDBytes.8)
    data.append(namespaceUUIDBytes.9)
    data.append(namespaceUUIDBytes.10)
    data.append(namespaceUUIDBytes.11)
    data.append(namespaceUUIDBytes.12)
    data.append(namespaceUUIDBytes.13)
    data.append(namespaceUUIDBytes.14)
    data.append(namespaceUUIDBytes.15)
    data.append(nameData)

    // SHA1 Hashing
    let hash = Insecure.SHA1.hash(data: data)

    // Umwandlung des Digest in UUIDv5
    var uuidBytes: [UInt8] = Array(hash)

    // Set the version to 5
    uuidBytes[6] &= 0x0F
    uuidBytes[6] |= 0x50

    // Set the variant to DCE 1.1 (NCS backwards compatible)
    uuidBytes[8] &= 0x3F
    uuidBytes[8] |= 0x80

    return UUID(uuid: (
        uuidBytes[0], uuidBytes[1], uuidBytes[2], uuidBytes[3], uuidBytes[4], uuidBytes[5], uuidBytes[6], uuidBytes[7],
        uuidBytes[8], uuidBytes[9], uuidBytes[10], uuidBytes[11], uuidBytes[12], uuidBytes[13], uuidBytes[14], uuidBytes[15]
    ))
}
