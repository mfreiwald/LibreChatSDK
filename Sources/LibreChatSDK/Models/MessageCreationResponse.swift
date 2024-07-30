import Foundation

public struct MessageCreationResponse: Codable {
    public struct MessageContent: Codable {
        public let messageId: String
        public let parentMessageId: String
        public let conversationId: String
        public let sender: String
        public let text: String
        public let isCreatedByUser: Bool

        public init(messageId: String, parentMessageId: String, conversationId: String, sender: String, text: String, isCreatedByUser: Bool) {
            self.messageId = messageId
            self.parentMessageId = parentMessageId
            self.conversationId = conversationId
            self.sender = sender
            self.text = text
            self.isCreatedByUser = isCreatedByUser
        }
    }

    public let message: MessageContent
    public let created: Bool

    public init(message: MessageContent, created: Bool) {
        self.message = message
        self.created = created
    }
}
