import Foundation
import RealHTTP

public struct User: Codable, Equatable, Hashable, Identifiable {
//    public let id: String
    public var id: String { email }
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

    public init(provider: String, email: String, name: String, username: String, avatar: String?, role: String, emailVerified: Bool, plugins: [String], createdAt: Date, updatedAt: Date) {
        self.provider = provider
        self.email = email
        self.name = name
        self.username = username
        self.avatar = avatar
        self.role = role
        self.emailVerified = emailVerified
        self.plugins = plugins
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
