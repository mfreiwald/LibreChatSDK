import Foundation

public struct MessageCreationResponse: Codable {
    public struct MessageContent: Codable {
        public let messageId: String
        public let parentMessageId: String
        public let conversationId: String
        public let sender: String
        public let text: String
        public let isCreatedByUser: Bool
    }

    public let message: MessageContent
    public let created: Bool
}
