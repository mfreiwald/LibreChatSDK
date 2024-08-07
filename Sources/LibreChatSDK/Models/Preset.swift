import Foundation

public struct Preset: Codable {
    public let _id: String
    public let user: String
    public let presetId: String
    public let __v: Int
    public let agentOptions: AgentOptions?
    public let chatGptLabel: String
    public let createdAt: Date
    public let endpoint: String
    public let examples: [String]?
    public let frequency_penalty: Double
    public let imageDetail: String
    public let model: String
    public let presence_penalty: Double
    public let promptPrefix: String
    public let resendImages: Bool
    public let temperature: Double
    public let title: String
    public let top_p: Double
    public let updatedAt: Date

    public init(
        _id: String,
        user: String,
        presetId: String,
        __v: Int,
        agentOptions: AgentOptions?,
        chatGptLabel: String,
        createdAt: Date,
        endpoint: String,
        examples: [String]?,
        frequency_penalty: Double,
        imageDetail: String,
        model: String,
        presence_penalty: Double,
        promptPrefix: String,
        resendImages: Bool,
        temperature: Double,
        title: String,
        top_p: Double,
        updatedAt: Date
    ) {
        self._id = _id
        self.user = user
        self.presetId = presetId
        self.__v = __v
        self.agentOptions = agentOptions
        self.chatGptLabel = chatGptLabel
        self.createdAt = createdAt
        self.endpoint = endpoint
        self.examples = examples
        self.frequency_penalty = frequency_penalty
        self.imageDetail = imageDetail
        self.model = model
        self.presence_penalty = presence_penalty
        self.promptPrefix = promptPrefix
        self.resendImages = resendImages
        self.temperature = temperature
        self.title = title
        self.top_p = top_p
        self.updatedAt = updatedAt
    }
}

typealias Presets = [Preset]
