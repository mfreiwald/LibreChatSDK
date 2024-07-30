import Foundation

public struct Conversations: Codable {
    public let conversations: [Conversation]
    public let pages: Int
    public let pageNumber: Int
    public let pageSize: Int

    public init(
        conversations: [Conversation],
        pages: Int,
        pageNumber: Int,
        pageSize: Int
    ) {
        self.conversations = conversations
        self.pages = pages
        self.pageNumber = pageNumber
        self.pageSize = pageSize
    }
}

public struct Conversation: Codable, Equatable, Hashable {
    public let id: String
    public let conversationId: String
    public let user: String
    public let chatGptLabel: String?
    public let createdAt: Date
    public let endpoint: String
    public let endpointType: String?
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
    public let agentOptions: AgentOptions?
    public let isArchived: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case conversationId
        case user
        case agentOptions
        case chatGptLabel
        case createdAt
        case endpoint
        case endpointType
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
        case isArchived
    }

    public init(
        id: String,
        conversationId: String,
        user: String,
        chatGptLabel: String?,
        createdAt: Date,
        endpoint: String,
        endpointType: String?,
        frequencyPenalty: Double,
        messages: [String],
        model: String,
        presencePenalty: Double,
        promptPrefix: String?,
        temperature: Double,
        title: String,
        top_p: Double,
        updatedAt: Date,
        imageDetail: String?,
        resendImages: Bool?,
        agentOptions: AgentOptions?,
        isArchived: Bool?
    ) {
        self.id = id
        self.conversationId = conversationId
        self.user = user
        self.chatGptLabel = chatGptLabel
        self.createdAt = createdAt
        self.endpoint = endpoint
        self.endpointType = endpointType
        self.frequencyPenalty = frequencyPenalty
        self.messages = messages
        self.model = model
        self.presencePenalty = presencePenalty
        self.promptPrefix = promptPrefix
        self.temperature = temperature
        self.title = title
        self.top_p = top_p
        self.updatedAt = updatedAt
        self.imageDetail = imageDetail
        self.resendImages = resendImages
        self.agentOptions = agentOptions
        self.isArchived = isArchived
    }
}

public struct AgentOptions: Codable, Equatable, Hashable {
    public let agent: String
    public let skipCompletion: Bool?
    public let model: String?
    public let temperature: Double?

    public init(
        agent: String,
        skipCompletion: Bool?,
        model: String?,
        temperature: Double?
    ) {
        self.agent = agent
        self.skipCompletion = skipCompletion
        self.model = model
        self.temperature = temperature
    }
}
