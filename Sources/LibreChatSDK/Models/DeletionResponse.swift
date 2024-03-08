import Foundation

public struct DeletionResponse: Codable {
    public let acknowledged: Bool
    public let deletedCount: Int
    public let messages: DeleteMessagesDetail

    public struct DeleteMessagesDetail: Codable {
        public let acknowledged: Bool
        public let deletedCount: Int
    }
}
