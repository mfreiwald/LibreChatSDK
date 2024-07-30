import Foundation

public struct MessageQueryResponse: Codable {
    public let text: String
    public let message: Bool
    public let initial: Bool

    public init(text: String, message: Bool, initial: Bool) {
        self.text = text
        self.message = message
        self.initial = initial
    }
}
