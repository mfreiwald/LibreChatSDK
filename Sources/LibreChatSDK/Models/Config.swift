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

    public init(
        appTitle: String,
        socialLogins: [String],
        discordLoginEnabled: Bool,
        facebookLoginEnabled: Bool,
        githubLoginEnabled: Bool,
        googleLoginEnabled: Bool,
        openidLoginEnabled: Bool,
        openidLabel: String?,
        openidImageUrl: String?,
        serverDomain: String,
        emailLoginEnabled: Bool,
        registrationEnabled: Bool,
        socialLoginEnabled: Bool,
        emailEnabled: Bool,
        checkBalance: Bool,
        showBirthdayIcon: Bool
    ) {
        self.appTitle = appTitle
        self.socialLogins = socialLogins
        self.discordLoginEnabled = discordLoginEnabled
        self.facebookLoginEnabled = facebookLoginEnabled
        self.githubLoginEnabled = githubLoginEnabled
        self.googleLoginEnabled = googleLoginEnabled
        self.openidLoginEnabled = openidLoginEnabled
        self.openidLabel = openidLabel
        self.openidImageUrl = openidImageUrl
        self.serverDomain = serverDomain
        self.emailLoginEnabled = emailLoginEnabled
        self.registrationEnabled = registrationEnabled
        self.socialLoginEnabled = socialLoginEnabled
        self.emailEnabled = emailEnabled
        self.checkBalance = checkBalance
        self.showBirthdayIcon = showBirthdayIcon
    }
}
