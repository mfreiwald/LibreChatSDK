import Foundation

public struct ChatResponse: Codable {
    public let title: String
    public let final: Bool
    public let conversation: Conversation
    public let requestMessage: MessageDetail
    public let responseMessage: ResponseMessageDetail

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

