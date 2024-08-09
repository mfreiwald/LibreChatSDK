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

    private let responseLogger = Logger(subsystem: "LibreChatSDK", category: "Response")

    public init(configuration: LibreChatConfiguration) {
        self.configuration = configuration
        client = .libreChat(configuration: configuration)
    }

    // MARK: Unauthorized calls

    public func config() async throws -> Config {
        let request = try HTTPRequest("config")
        let response = try await fetch(request, authenticationRequired: false)
        return try decode(response)
    }

    public func endpoints() async throws -> Endpoints {
        let request = try HTTPRequest("endpoints")
        let response = try await fetch(request, authenticationRequired: false)
        return try decode(response)
    }

    public func login(email: String, password: String) async throws {
        let request = try HTTPRequest(method: .post, "auth/login")
        request.body = .json(UserCredentials(email: email, password: password))

        let response = try await request.fetch(client)

        if let refreshToken = extractRefreshToken(response.headers, headerName: .setCookie) {
            async let _ = configuration.refreshTokenProvider.updateRefreshToken(refreshToken)
            client.headers[.cookie] = "refreshToken=\(refreshToken)"
        } else {
            // TODO: Throw error, no refresh token
        }

        let token = try response.decode(TokenResponse.self, decoder: .iso8601Full)
        client.headers.set(.authorization, "Bearer \(token.token)")
    }

    // MARK: Authorized calls

    public func logout() async throws {
        let request = try HTTPRequest("auth/logout")
        try await fetch(request)
        client.headers[.cookie] = nil
        client.headers[.authorization] = nil
    }

    public func user() async throws -> User {
        let request = try HTTPRequest("user")
        let response = try await fetch(request)
        return try decode(response)
    }

    // TOOD: Needs testing..
    public func keys(name: String, expiresAt: Date, apiKey: String, baseUrl: String?) async throws {
        struct RequestBody: Encodable {
            let name: String
            let expiresAt: Date
            let value: String
        }

        let dataBody = RequestBody(
            name: name,
            expiresAt: expiresAt,
            value: "{\"apiKey\":\"\(apiKey)\",\"baseURL\":\"\(baseUrl ?? "")\"}"
        )

        let data = try JSONEncoder.iso8601Full.encode(dataBody)

        let request = try HTTPRequest(method: .put, "keys")
        request.body = .data(data, contentType: .json)
        try await fetch(request)
    }

    public func keys(_ endpoint: String) async throws -> String? {
        struct Response: Decodable {
            let expiresAt: String?
        }
        let request = try HTTPRequest("keys", params: ["name": endpoint])
        let response = try await fetch(request)
        let value: Response = try decode(response)
        return value.expiresAt
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

    public func uploadImage(_ data: Data) async throws -> ChatFile {
        let request = try HTTPRequest(method: .post, "files/images")
        request.body = .multipart({ form in
            form.add(data: data, name: "file", fileName: "file.png", mimeType: "image/png")
        })
        let response = try await fetch(request)
        return try decode(response)
    }

    public func ask(
        endpoint: String,
        message: MessageInfo
    ) async throws -> AskHandler {
        let request = try HTTPRequest(method: .post, URI: "ask/{endpoint}", variables: ["endpoint": endpoint])
        request.body = .json(message)
        
        let req = try await request.urlRequest(inClient: client)
        let urlString = req.url?.absoluteString ?? ""
        logger.info("➡️ [\(urlString)]")
//        logger.info("\(req.headers.asDictionary)")

        var (bytes, response) = try await client.session.bytes(for: req)

        guard let httpResponse = response as? HTTPURLResponse else { throw HTTPError(.invalidResponse) }
        guard let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) else { throw HTTPError(.invalidResponse) }

        if statusCode == .unauthorized {
            // TODO: Copy&Pasted from HTTPAltRequestValidator - move to function
            guard let refreshToken = configuration.refreshTokenProvider.refreshToken() else { throw HTTPError(.network) }
            let refreshRequest = try HTTPRequest(method: .post, "auth/refresh")
            refreshRequest.headers[.cookie] = "refreshToken=\(refreshToken)"
            let refreshResponse = try await refreshRequest.fetch(client)

            if let refreshToken = extractRefreshToken(refreshResponse.headers, headerName: .setCookie) {
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

        return await AskHandler(bytes: bytes)
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

    public func archiveConversation(conversationId: String) async throws -> Conversation {
        let request = try HTTPRequest(method: .post, "convos/update")
        request.body = try .json(["arg": ["conversationId": conversationId, "isArchived": true]])
        let response = try await fetch(request)
        return try decode(response)
    }

    public func deleteConversation(conversationId: String) async throws -> DeletionResponse {
        let request = try HTTPRequest(method: .post, "convos/clear")
        request.body = .json(["arg": ["conversationId": conversationId, "source": "button"]])
        let response = try await fetch(request)
        return try decode(response)
    }

    @discardableResult
    private func fetch(_ request: HTTPRequest, authenticationRequired: Bool = true) async throws -> HTTPResponse {
        let urlRquest = try await request.urlRequest(inClient: client)
        
        let urlString = urlRquest.url?.absoluteString ?? ""
        logger.info("➡️ [\(urlString)]")
        logger.debug("\(urlRquest.headers.asDictionary)")

        if authenticationRequired {
            let refreshToken = extractRefreshToken(urlRquest.headers, headerName: .cookie) ?? ""
            if refreshToken.isEmpty {
                if let refreshToken = configuration.refreshTokenProvider.refreshToken(), !refreshToken.isEmpty {
                    client.headers[.cookie] = "refreshToken=\(refreshToken)"
                } else {
                    logger.error("⬅️ [\(urlString)] Authentication requests needs Refreshtoken")
                    throw HTTPError.init(.sessionError, message: "Authentication requests needs Refreshtoken")
                }
            }
        }

        do {
            let response = try await request.fetch(client)
            logger.info("⬅️ [\(urlString)] StatusCode: \(response.statusCode.rawValue)")
            return response
        } catch let error as HTTPError {
            logger.error("⬅️ [\(urlString)] StatusCode: \(error.statusCode.rawValue) (\(error))")
            throw error
        } catch {
            logger.error("⬅️ [\(urlString)] \(error.localizedDescription)")
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
                logger.info("➡️ [\(refreshRequest.url?.relativePath ?? "")] for [\(request.url?.relativePath ?? "")]")
                logger.debug("\(refreshRequest.headers.asDictionary)")

                return refreshRequest
            } catch {
                return nil
            }
        }, onReceiveAltResponse: { request, response in
            if let error = response.error {
                logger.info("⬅️ [\(request.url?.relativePath ?? "")] StatusCode: \(response.statusCode.rawValue) (\(error))")
            } else {
                logger.info("⬅️ [\(request.url?.relativePath ?? "")] StatusCode: \(response.statusCode.rawValue)")
            }

            if let refreshToken = extractRefreshToken(response.headers, headerName: .setCookie) {
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

private func extractRefreshToken(_ headers: HTTPHeaders, headerName: HTTPHeaders.Element.Name) -> String? {
    guard let setCookie = headers[.setCookie] else { return nil }
    guard let refreshTokenPair = setCookie.split(separator: "; ").first(where: { $0.starts(with: "refreshToken=")}) else { return nil }
    guard let refreshToken = refreshTokenPair.split(separator: "=").last else { return nil }
    return String(refreshToken)
}

public struct ErrorResponse: Error, Decodable {
    public let text: String

    public init(text: String) {
        self.text = text
    }
}

public actor AskHandler {
    public var creationResponse: MessageCreationResponse {
        get async throws {
            for try await value in self.creationResponseStream {
                return value
            }
            throw ErrorResponse(text: "Didn't received any Creation Response")
        }
    }

    public var chatResponse: ChatResponse {
        get async throws {
            for try await value in self.chatResponseStream {
                return value
            }
            throw ErrorResponse(text: "Didn't received any Chat Response")
        }
    }

    private let creationResponseStream: AsyncThrowingStream<MessageCreationResponse, Error>
    private let creationResponseContinuation: AsyncThrowingStream<MessageCreationResponse, Error>.Continuation

    private var isCreationResponseFinished = false

    private func creationResponseFinished() {
        isCreationResponseFinished = true
    }

    public let queryResponseStream: AsyncStream<MessageQueryResponse>
    private let queryResponseContinuation: AsyncStream<MessageQueryResponse>.Continuation

    private let chatResponseStream: AsyncThrowingStream<ChatResponse, Error>
    private let chatResponseContinuation: AsyncThrowingStream<ChatResponse, Error>.Continuation

    private var task: Task<Void, Error>?

    init(bytes: URLSession.AsyncBytes) async {
        (creationResponseStream, creationResponseContinuation) = AsyncThrowingStream.makeStream()
        (queryResponseStream, queryResponseContinuation) = AsyncStream.makeStream()
        (chatResponseStream, chatResponseContinuation) = AsyncThrowingStream.makeStream()

        task = Task { try await start(bytes) }
    }

    public init(
        creationResponseStream: AsyncThrowingStream<MessageCreationResponse, Error>,
        creationResponseContinuation: AsyncThrowingStream<MessageCreationResponse, Error>.Continuation,
        queryResponseStream: AsyncStream<MessageQueryResponse>,
        queryResponseContinuation: AsyncStream<MessageQueryResponse>.Continuation,
        chatResponseStream: AsyncThrowingStream<ChatResponse, Error>,
        chatResponseContinuation: AsyncThrowingStream<ChatResponse, Error>.Continuation
    ) {
        self.creationResponseStream = creationResponseStream
        self.creationResponseContinuation = creationResponseContinuation
        self.queryResponseStream = queryResponseStream
        self.queryResponseContinuation = queryResponseContinuation
        self.chatResponseStream = chatResponseStream
        self.chatResponseContinuation = chatResponseContinuation
    }

    deinit {
        task?.cancel()
        task = nil
    }

    private func start(_ bytes: URLSession.AsyncBytes) async throws {
        for try await line in bytes.lines {
            let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            guard components.count == 2, components[0] == "data" else { continue } // TODO: Es gibt auch components[0] == "event: message" -> data: {}, "event: error" -> data: {}
            let message = components[1].trimmingCharacters(in: .whitespacesAndNewlines)

            guard let data = message.data(using: .utf8) else { continue }

            if let messageResponse = try? JSONDecoder.iso8601Full.decode(MessageCreationResponse.self, from: data) {
                creationResponseContinuation.yield(messageResponse)
                creationResponseFinished()
                creationResponseContinuation.finish()
            } else if let userQuery = try? JSONDecoder.iso8601Full.decode(MessageQueryResponse.self, from: data) {

                queryResponseContinuation.yield(userQuery)
            } else if let chatResponse = try? JSONDecoder.iso8601Full.decode(ChatResponse.self, from: data) {
                queryResponseContinuation.finish()
                chatResponseContinuation.yield(chatResponse)
                chatResponseContinuation.finish()
            } else if let errorResponse = try? JSONDecoder.iso8601Full.decode(ErrorResponse.self, from: data) {
                if isCreationResponseFinished {
                    queryResponseContinuation.finish()
                    chatResponseContinuation.finish(throwing: errorResponse)
                } else {
                    creationResponseContinuation.finish(throwing: errorResponse)
                }
            } else {
                continue
            }
        }
    }
}
