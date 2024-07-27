import Foundation

public struct Message: Codable, Equatable, Hashable {
    public var id: String { messageId }
    public let messageId: String
    public let conversationId: String
    public let createdAt: Date
    public let endpoint: String?
    public let error: Bool
    public let isCreatedByUser: Bool
    public let isEdited: Bool
    public let model: String?
    public let parentMessageId: String
    public let sender: String
    public let text: String
    public let tokenCount: Int?
    public let unfinished: Bool
    public let updatedAt: Date
//    public let user: String
    public let finishReason: String?
    public let files: [FileId]?

    private enum CodingKeys: String, CodingKey {
        case messageId
        case conversationId, createdAt, endpoint, error, isCreatedByUser, isEdited, model, parentMessageId, sender, text, tokenCount, unfinished, updatedAt
        case files
        case finishReason = "finish_reason"
    }

    public struct FileId: Codable, Equatable, Hashable {
        public let fileId: String

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
        }
    }
}
