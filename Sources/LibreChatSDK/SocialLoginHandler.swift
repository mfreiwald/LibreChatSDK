import Foundation
import AuthenticationServices

class SocialLoginHandler {
    private let contextProvider: ASWebAuthenticationPresentationContextProviding
    private var session: ASWebAuthenticationSession?

    init(contextProvider: ASWebAuthenticationPresentationContextProviding) {
        self.contextProvider = contextProvider
    }

    @MainActor
    func authenticate(with social: SocialLogin, baseUrl: URL, callbackScheme: String, callbackUri: String) async throws -> (token: String, refreshToken: String) {
        defer {
            session = nil
        }
        return try await withCheckedThrowingContinuation { @MainActor continuation in
            var url = baseUrl.appending(path: "oauth").appending(path: social.rawValue).appending(queryItems: [.init(name: "redirect", value: callbackUri)])

            session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme) { callbackURL, error in
                if let error {
                    continuation.resume(throwing: error)
                }
                guard
                    error == nil,
                    let callbackURL = callbackURL,
                    let queryItems = URLComponents(string: callbackURL.absoluteString)?
                        .queryItems,
                    let token = queryItems.first(where: { $0.name == "token" })?.value,
                    let refreshToken = queryItems.first(where: { $0.name == "refreshToken" })?.value
                else {
                    // TODO: continuation.resume(throwing: )
                    return // TODO: Throw error
                }
                continuation.resume(returning: (token: token, refreshToken: refreshToken))
            }

            session?.presentationContextProvider = contextProvider
            session?.start()
        }
    }
}
