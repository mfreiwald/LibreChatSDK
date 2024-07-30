import Foundation

public struct ChatResponse: Codable {
    public let title: String
    public let final: Bool
    public let conversation: Conversation
    public let requestMessage: MessageDetail
    public let responseMessage: ResponseMessageDetail

    public init(title: String, final: Bool, conversation: Conversation, requestMessage: MessageDetail, responseMessage: ResponseMessageDetail) {
        self.title = title
        self.final = final
        self.conversation = conversation
        self.requestMessage = requestMessage
        self.responseMessage = responseMessage
    }

    public struct MessageDetail: Codable {
        public let messageId: String
        public let parentMessageId: String
        public let conversationId: String
        public let sender: String
        public let text: String
        public let isCreatedByUser: Bool
        public let tokenCount: Int?

        public init(messageId: String, parentMessageId: String, conversationId: String, sender: String, text: String, isCreatedByUser: Bool, tokenCount: Int?) {
            self.messageId = messageId
            self.parentMessageId = parentMessageId
            self.conversationId = conversationId
            self.sender = sender
            self.text = text
            self.isCreatedByUser = isCreatedByUser
            self.tokenCount = tokenCount
        }
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

        public init(messageId: String, conversationId: String, parentMessageId: String, isCreatedByUser: Bool, model: String, sender: String, text: String, promptTokens: Int?, finish_reason: String, endpoint: String) {
            self.messageId = messageId
            self.conversationId = conversationId
            self.parentMessageId = parentMessageId
            self.isCreatedByUser = isCreatedByUser
            self.model = model
            self.sender = sender
            self.text = text
            self.promptTokens = promptTokens
            self.finish_reason = finish_reason
            self.endpoint = endpoint
        }
    }
}

