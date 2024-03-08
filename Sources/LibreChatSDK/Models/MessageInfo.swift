import Foundation

public struct MessageInfo: Codable {
    public let text: String
    public let sender: String
    public let isCreatedByUser: Bool
    public let parentMessageId: String
    public let conversationId: String?
    public let messageId: String
    public let error: Bool
    public let generation: String?
    public let responseMessageId: String?
    public let overrideParentMessageId: String?
    public let model: String
    public let endpoint: String
    public let key: String?
    public let isContinued: Bool
    public let temperature: Double?
    public let tools: [Tool]?
    public let agentOptions: AgentOptions?

    public init(
        text: String,
        sender: String,
        isCreatedByUser: Bool,
        parentMessageId: String,
        conversationId: String?,
        messageId: String,
        error: Bool,
        generation: String?,
        responseMessageId: String?,
        overrideParentMessageId: String?,
        model: String,
        endpoint: String,
        key: String?,
        isContinued: Bool,
        temperature: Double?,
        tools: [Tool]?,
        agentOptions: AgentOptions?
    ) {
        self.text = text
        self.sender = sender
        self.isCreatedByUser = isCreatedByUser
        self.parentMessageId = parentMessageId
        self.conversationId = conversationId
        self.messageId = messageId
        self.error = error
        self.generation = generation
        self.responseMessageId = responseMessageId
        self.overrideParentMessageId = overrideParentMessageId
        self.model = model
        self.endpoint = endpoint
        self.key = key
        self.isContinued = isContinued
        self.temperature = temperature
        self.tools = tools
        self.agentOptions = agentOptions
    }
}

public struct Tool: Codable {
    public let name: String
    public let pluginKey: String
    public let description: String
    public let icon: String
    public let authConfig: [AuthConfig]
    public let authenticated: Bool?

    public struct AuthConfig: Codable {
        public let authField: String
        public let label: String
        public let description: String
    }
}
