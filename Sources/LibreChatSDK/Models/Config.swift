import Foundation

public struct Config: Codable, Equatable, Hashable {
    public let appTitle: String
    public let socialLogins: [String]
    public let discordLoginEnabled: Bool
    public let facebookLoginEnabled: Bool
    public let githubLoginEnabled: Bool
    public let googleLoginEnabled: Bool
    public let openidLoginEnabled: Bool
    public let openidLabel: String?
    public let openidImageUrl: String?
    public let serverDomain: String
    public let emailLoginEnabled: Bool
    public let registrationEnabled: Bool
    public let socialLoginEnabled: Bool
    public let emailEnabled: Bool
    public let checkBalance: Bool
    public let showBirthdayIcon: Bool
}
