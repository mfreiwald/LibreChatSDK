import Foundation

public struct LibreChatConfiguration {
    public struct RefreshTokenProvider {
        var refreshToken: () -> String?
        var updateRefreshToken: (String) async -> Void

        public init(refreshToken: @escaping () -> String?, updateRefreshToken: @escaping (String) async -> Void) {
            self.refreshToken = refreshToken
            self.updateRefreshToken = updateRefreshToken
        }

        public static func userDefaults(key: String, defaults: UserDefaults = .standard) -> RefreshTokenProvider {
            RefreshTokenProvider {
                defaults.string(forKey: key)
            } updateRefreshToken: {
                defaults.setValue($0, forKey: key)
            }
        }
    }

    public var baseUrl: URL
    public var userAgent: String
    public var refreshTokenProvider: RefreshTokenProvider

    public init(
        baseUrl: URL,
        userAgent: String,
        refreshTokenProvider: RefreshTokenProvider
    ) {
        self.baseUrl = baseUrl
        self.userAgent = userAgent
        self.refreshTokenProvider = refreshTokenProvider
    }
}
