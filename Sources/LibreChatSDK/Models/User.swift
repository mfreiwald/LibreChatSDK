import Foundation
import RealHTTP

public struct User: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let provider: String
    public let email: String
    public let name: String
    public let username: String
    public let avatar: String?
    public let role: String
    public let emailVerified: Bool
    public let plugins: [String]
    public let createdAt: Date
    public let updatedAt: Date
}
