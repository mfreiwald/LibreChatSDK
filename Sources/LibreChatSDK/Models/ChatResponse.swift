import Foundation

public struct ChatResponse: Codable {
    public let title: String
    public let final: Bool
    public let conversation: ConversationDetail
    public let requestMessage: MessageDetail
    public let responseMessage: ResponseMessageDetail

    public struct ConversationDetail: Codable { // TODO: Compare to Conversation struct
        public let _id: String
        public let conversationId: String
        public let user: String
        public let __v: Int
        public let chatGptLabel: String?
        public let createdAt: Date
        public let endpoint: String
        public let frequency_penalty: Double
        public let imageDetail: String
        public let messages: [String]
        public let model: String
        public let presence_penalty: Double
        public let promptPrefix: String?
        public let resendImages: Bool
        public let temperature: Double
        public let title: String
        public let top_p: Double
        public let updatedAt: Date
    }

    public struct MessageDetail: Codable {
        public let messageId: String
        public let parentMessageId: String
        public let conversationId: String
        public let sender: String
        public let text: String
        public let isCreatedByUser: Bool
        public let tokenCount: Int?
    }

    public struct ResponseMessageDetail: Codable {
        public let messageId: String
        public let conversationId: String
        public let parentMessageId: String
        public let isCreatedByUser: Bool
        public let model: String
        public let sender: String
        public let text: String
        public let promptTokens: Int?
        public let finish_reason: String
        public let endpoint: String
    }
}

