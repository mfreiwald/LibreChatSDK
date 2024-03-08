import OSLog
import RealHTTP
import Foundation

let logger = Logger(subsystem: "LibreChatSDK", category: "LibreChatClient")

public enum LibreChatError: String, Error {
    case fatalError
}

public enum SocialLogin: String {
    case openId = "openid"
    case github = "github"
}

public class LibreChatClient {
    let configuration: LibreChatConfiguration
    let client: HTTPClient
    private let socialLoginHandler: SocialLoginHandler

    private let responseLogger = Logger(subsystem: "LibreChatSDK", category: "Response")

    public init(configuration: LibreChatConfiguration) {
        self.configuration = configuration
        client = .libreChat(configuration: configuration)
        socialLoginHandler = SocialLoginHandler(contextProvider: configuration.socialLoginContextProvider)
    }

    // MARK: Unauthorized calls

    public func config() async throws -> Config {
        let request = try HTTPRequest("config")
        let response = try await fetch(request)
        return try decode(response)
    }

    public func endpoints() async throws -> Endpoints {
        let request = try HTTPRequest("endpoints")
        let response = try await fetch(request)
        return try decode(response)
    }

    public func login(email: String, password: String) async throws {
        let request = try HTTPRequest(method: .post, "auth/login")
        request.body = .json(UserCredentials(email: email, password: password))

        let response = try await request.fetch(client)

        if let refreshToken = extractRefreshToken(response.headers) {
            async let _ = configuration.refreshTokenProvider.updateRefreshToken(refreshToken)
            client.headers[.cookie] = "refreshToken=\(refreshToken)"
        } else {
            // TODO: Throw error, no refresh token
        }

        let token = try response.decode(TokenResponse.self, decoder: .iso8601Full)
        client.headers.set(.authorization, "Bearer \(token.token)")
    }

    public func login(social: SocialLogin) async throws {
        let (token, refreshToken) = try await socialLoginHandler.authenticate(with: social, baseUrl: configuration.baseUrl, callbackScheme: configuration.callbackScheme, callbackUri: configuration.callbackUri)
        async let _ = configuration.refreshTokenProvider.updateRefreshToken(refreshToken)
        client.headers[.cookie] = "refreshToken=\(refreshToken)"
        client.headers.set(.authorization, "Bearer \(token)")
    }

    // MARK: Authorized calls

    public func user() async throws -> User {
        let request = try HTTPRequest("user")
        let response = try await fetch(request)
        return try decode(response)
    }

    public func conversations(pageNumber: Int = 1) async throws -> Conversations {
        let request = try HTTPRequest("convos", params: ["pageNumber": pageNumber])
        let response = try await fetch(request)
        return try decode(response)
    }

    public func conversation(conversationId: String) async throws -> Conversation {
        let request = try HTTPRequest(URI: "convos/{conversationId}", variables: ["conversationId": conversationId])
        let response = try await fetch(request)
        return try decode(response)
    }

    public func messages(conversationId: String) async throws -> [Message] {
        let request = try HTTPRequest(URI: "messages/{conversationId}", variables: ["conversationId": conversationId])
        let response = try await fetch(request)
        return try decode(response)
    }

    public func presets() async throws -> [Preset] {
        let request = try HTTPRequest("presets")
        let response = try await fetch(request)
        return try decode(response)
    }

    public func plugins() async throws -> [Plugin] {
        let request = try HTTPRequest("plugins")
        let response = try await fetch(request)
        return try decode(response)
    }

    public func models() async throws -> Models {
        let request = try HTTPRequest("models")
        let response = try await fetch(request)
        return try decode(response)
    }

    public func files() async throws -> [ChatFile] {
        let request = try HTTPRequest("files")
        let response = try await fetch(request)
        return try decode(response)
    }

    public func deleteFiles(_ files: DeleteFileRequest) async throws -> String? {
        let request = try HTTPRequest(method: .delete, "files")
        request.body = .json(files)
        let response = try await fetch(request)
        let json: [String: String] = try decode(response)
        return json["message"]
    }

    public func ask(
        endpoint: String,
        message: MessageInfo,
        creationResponse: ((MessageCreationResponse) -> Void)? = nil,
        queryResponse: ((MessageQueryResponse) -> Void)? = nil
    ) async throws -> ChatResponse {
        let request = try HTTPRequest(method: .post, URI: "ask/{endpoint}", variables: ["endpoint": endpoint])
        request.body = .json(message)
        
        let req = try await request.urlRequest(inClient: client)
        var (bytes, response) = try await client.session.bytes(for: req)

        guard let httpResponse = response as? HTTPURLResponse else { throw HTTPError(.invalidResponse) }
        guard let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) else { throw HTTPError(.invalidResponse) }

        if statusCode == .unauthorized {
            // TODO: Copy&Pasted from HTTPAltRequestValidator - move to function
            guard let refreshToken = configuration.refreshTokenProvider.refreshToken() else { throw HTTPError(.network) }
            let refreshRequest = try HTTPRequest(method: .post, "auth/refresh")
            refreshRequest.headers[.cookie] = "refreshToken=\(refreshToken)"
            let refreshResponse = try await refreshRequest.fetch(client)

            if let refreshToken = extractRefreshToken(refreshResponse.headers) {
                async let _ = configuration.refreshTokenProvider.updateRefreshToken(refreshToken)
                client.headers[.cookie] = "refreshToken=\(refreshToken)"
            }

            let receivedToken = try refreshResponse.decode(TokenResponse.self, decoder: .iso8601Full)
            client.headers.set(.authorization, "Bearer \(receivedToken.token)")
            (bytes, response) = try await client.session.bytes(for: req)
            guard let httpResponse = response as? HTTPURLResponse else { throw HTTPError(.invalidResponse) }
            guard let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) else { throw HTTPError(.invalidResponse) }
            guard (200..<400).contains(statusCode.rawValue) else { throw HTTPError(.network, code: statusCode) }
        }

        for try await line in bytes.lines {
            let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            guard components.count == 2, components[0] == "data" else { continue }
            let message = components[1].trimmingCharacters(in: .whitespacesAndNewlines)

            guard let data = message.data(using: .utf8) else { continue }

            if let messageResponse = try? JSONDecoder.iso8601Full.decode(MessageCreationResponse.self, from: data) {
                creationResponse?(messageResponse)
            } else if let userQuery = try? JSONDecoder.iso8601Full.decode(MessageQueryResponse.self, from: data) {
                queryResponse?(userQuery)
            } else if let chatResponse = try? JSONDecoder.iso8601Full.decode(ChatResponse.self, from: data) {
                return chatResponse
            } else {
                continue
            }
        }
        throw HTTPError(.other, message: "No final chat response received")
    }

    public func generateConversationTitle(conversationId: String) async throws -> String {
        let request = try HTTPRequest(method: .post, "convos/gen_title")
        request.body = .json(["conversationId": conversationId])
        let response = try await fetch(request)
        let json: [String: String] = try decode(response)
        if let title = json["title"] {
            return title
        } else {
            throw HTTPError(.objectDecodeFailed, message: "No title in response")
        }
    }

    public func updateConversationTitle(_ title: String, conversationId: String) async throws -> Conversation {
        let request = try HTTPRequest(method: .post, "convos/update")
        request.body = .json(["arg": ["conversationId": conversationId, "title": title]])
        let response = try await fetch(request)
        return try decode(response)
    }

    public func deleteConversation(conversationId: String) async throws -> DeletionResponse {
        let request = try HTTPRequest(method: .post, "convos/clear")
        request.body = .json(["arg": ["conversationId": conversationId, "source": "button"]])
        let response = try await fetch(request)
        return try decode(response)
    }

    private func fetch(_ request: HTTPRequest) async throws -> HTTPResponse {
        do {
            logger.info("➡️ [\(request.url?.relativePath ?? "")]")
            let response = try await request.fetch(client)
            logger.info("⬅️ [\(request.url?.relativePath ?? "")] StatusCode: \(response.statusCode.rawValue) (\(response.statusCode.localizedDescription))")
            return response
        } catch let error as HTTPError {
            logger.error("⬅️ [\(request.url?.relativePath ?? "")] StatusCode: \(error.statusCode.rawValue) (\(error.statusCode.localizedDescription))")
            throw error
        } catch {
            logger.error("⬅️ [\(request.url?.relativePath ?? "")] \(error.localizedDescription)")
            throw error
        }
    }

    private func decode<Data>(_ response: HTTPResponse) throws -> Data where Data: Decodable {
        do {
            return try response.decode(Data.self, decoder: .iso8601Full)
        } catch let error as DecodingError {
            logResponseJson(response, error: error)
            throw error
        } catch {
            throw error
        }
    }

    private func logResponseJson(_ response: HTTPResponse, error: DecodingError) {
        if let data = response.data, let json = data.prettyPrintedJSONString {
            let url = response.httpResponse?.url?.absoluteString ?? ""
            let method = response.request?.method.rawValue ?? "nil"

            let log = """
    ‼️ \(error)
    ➡️ \(method): \(url)
    ⬅️ JSON-Response:
    \(json)
    """
            responseLogger.trace("\(log)")
        }
    }
}

extension HTTPClient {
    static func libreChat(configuration: LibreChatConfiguration) -> HTTPClient {
        let config = URLSessionConfiguration.default
        config.httpShouldSetCookies = true
        config.networkServiceType = .responsiveData

        let client = HTTPClient(baseURL: configuration.baseUrl.appending(path: "api"), configuration: config)

        // Setup some common HTTP Headers for all requests
        client.headers = HTTPHeaders(arrayLiteral:
                .init(name: .userAgent, value: configuration.userAgent)
        )

        if let refreshToken = configuration.refreshTokenProvider.refreshToken() {
            client.headers[.cookie] = "refreshToken=\(refreshToken)"
        }


        let authValidator = HTTPAltRequestValidator(statusCodes: [.unauthorized], onProvideAltRequest: { request, response in
            // refresh only possible when refeshToken available
            guard let refreshToken = configuration.refreshTokenProvider.refreshToken() else { 
                return nil
            }

            request.maxRetries += 1
            do {
                let refreshRequest = try HTTPRequest(method: .post, "auth/refresh")
                refreshRequest.headers[.cookie] = "refreshToken=\(refreshToken)"
                logger.info("➡️ [\(request.url?.relativePath ?? "")]")
                return refreshRequest
            } catch {
                return nil
            }
        }, onReceiveAltResponse: { request, response in
            logger.info("⬅️ [\(request.url?.relativePath ?? "")] StatusCode: \(response.statusCode.rawValue) (\(response.statusCode.localizedDescription))")

            if let refreshToken = extractRefreshToken(response.headers) {
                async let _ = configuration.refreshTokenProvider.updateRefreshToken(refreshToken)
                client.headers[.cookie] = "refreshToken=\(refreshToken)"
            }

            let receivedToken = try response.decode(TokenResponse.self, decoder: .iso8601Full)
            client.headers.set(.authorization, "Bearer \(receivedToken.token)")
        })

        // append at the top of the validators chain
        client.validators.insert(authValidator, at: 0)

        return client
    }
}

private func extractRefreshToken(_ header: HTTPHeaders) -> String? {
    guard let setCookie = header[.setCookie] else { return nil }
    guard let refreshTokenPair = setCookie.split(separator: "; ").first(where: { $0.starts(with: "refreshToken=")}) else { return nil }
    guard let refreshToken = refreshTokenPair.split(separator: "=").last else { return nil }
    return String(refreshToken)
}
