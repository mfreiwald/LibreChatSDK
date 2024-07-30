import Foundation

public struct Plugin: Codable {
    public let name: String
    public let pluginKey: String
    public let description: String
    public let icon: String
    public let isAuthRequired: String?
    public let authConfig: [PluginAuthConfig]
    public let authenticated: Bool?

    public init(name: String, pluginKey: String, description: String, icon: String, isAuthRequired: String?, authConfig: [PluginAuthConfig], authenticated: Bool?) {
        self.name = name
        self.pluginKey = pluginKey
        self.description = description
        self.icon = icon
        self.isAuthRequired = isAuthRequired
        self.authConfig = authConfig
        self.authenticated = authenticated
    }

    public struct PluginAuthConfig: Codable {
        public let authField: String
        public let label: String
        public let description: String

        public init(authField: String, label: String, description: String) {
            self.authField = authField
            self.label = label
            self.description = description
        }
    }
}
