import Foundation

public struct Conversations: Codable {
    public let conversations: [Conversation]
    public let pages: Int
    public let pageNumber: Int
    public let pageSize: Int
}

public struct Conversation: Codable, Equatable, Hashable {
    public let id: String
    public let conversationId: String
    public let user: String
    public let agentOptions: AgentOptions?
    public let chatGptLabel: String?
    public let createdAt: Date
    public let endpoint: String
    public let frequencyPenalty: Double
    public let messages: [String]
    public let model: String
    public let presencePenalty: Double
    public let promptPrefix: String?
    public let temperature: Double
    public var title: String
    public let top_p: Double
    public let updatedAt: Date
    public let imageDetail: String?
    public let resendImages: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case conversationId
        case user
        case agentOptions
        case chatGptLabel
        case createdAt
        case endpoint
        case frequencyPenalty = "frequency_penalty"
        case messages
        case model
        case presencePenalty = "presence_penalty"
        case promptPrefix
        case temperature
        case title
        case top_p
        case updatedAt
        case imageDetail
        case resendImages
    }
}

public struct AgentOptions: Codable, Equatable, Hashable {
    public let agent: String
    public let skipCompletion: Bool?
    public let model: String?
    public let temperature: Double?
}
