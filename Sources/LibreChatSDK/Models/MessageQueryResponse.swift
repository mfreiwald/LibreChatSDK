import Foundation

public struct MessageQueryResponse: Codable {
    public let text: String
    public let message: Bool
    public let initial: Bool
}
