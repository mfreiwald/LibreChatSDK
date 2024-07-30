import Foundation

public struct DeletionResponse: Codable {
    public let acknowledged: Bool
    public let deletedCount: Int
    public let messages: DeleteMessagesDetail

    public init(acknowledged: Bool, deletedCount: Int, messages: DeleteMessagesDetail) {
        self.acknowledged = acknowledged
        self.deletedCount = deletedCount
        self.messages = messages
    }
    
    public struct DeleteMessagesDetail: Codable {
        public let acknowledged: Bool
        public let deletedCount: Int

        public init(acknowledged: Bool, deletedCount: Int) {
            self.acknowledged = acknowledged
            self.deletedCount = deletedCount
        }
    }
}
