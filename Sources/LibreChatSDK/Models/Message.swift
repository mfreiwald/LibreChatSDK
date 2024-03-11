import Foundation

public struct Message: Codable, Equatable, Hashable {
    public let id: String
    public let messageId: String
    public let __v: Int
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
    public let tokenCount: Int
    public let unfinished: Bool
    public let updatedAt: Date
    public let user: String
    public let finishReason: String?
    public let files: [FileId]?

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case messageId, __v, conversationId, createdAt, endpoint, error, isCreatedByUser, isEdited, model, parentMessageId, sender, text, tokenCount, unfinished, updatedAt, user, files
        case finishReason = "finish_reason"
    }

    public struct FileId: Codable, Equatable, Hashable {
        public let fileId: String

        private enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
        }
    }
}
