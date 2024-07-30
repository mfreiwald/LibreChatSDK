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
    public let endpointType: String?
    public let key: String?
    public let isContinued: Bool
    public let temperature: Double?
    public let tools: [Tool]?
    public let agentOptions: AgentOptions?
    public let files: [FileMessageInfo]

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
        endpointType: String?,
        key: String?,
        isContinued: Bool,
        temperature: Double?,
        tools: [Tool]?,
        agentOptions: AgentOptions?,
        files: [FileMessageInfo]
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
        self.endpointType = endpointType
        self.key = key
        self.isContinued = isContinued
        self.temperature = temperature
        self.tools = tools
        self.agentOptions = agentOptions
        self.files = files
    }
}

public struct Tool: Codable {
    public let name: String
    public let pluginKey: String
    public let description: String
    public let icon: String
    public let authConfig: [AuthConfig]
    public let authenticated: Bool?

    public init(name: String, pluginKey: String, description: String, icon: String, authConfig: [AuthConfig], authenticated: Bool?) {
        self.name = name
        self.pluginKey = pluginKey
        self.description = description
        self.icon = icon
        self.authConfig = authConfig
        self.authenticated = authenticated
    }

    public struct AuthConfig: Codable {
        public let authField: String
        public let label: String
        public let description: String

        public init(authField: String, label: String, description: String) {
            self.authField = authField
            self.label = label
            self.description = description
        }
    }
}

public struct FileMessageInfo: Codable {
    public let fileId: String
    public let filepath: String
    public let height: Int
    public let type: String
    public let width: Int

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case filepath, height, type, width
    }

    public init(fileId: String, filepath: String, height: Int, type: String, width: Int) {
        self.fileId = fileId
        self.filepath = filepath
        self.height = height
        self.type = type
        self.width = width
    }
}
