import Foundation

public struct Plugin: Codable {
    public let name: String
    public let pluginKey: String
    public let description: String
    public let icon: String
    public let isAuthRequired: String?
    public let authConfig: [PluginAuthConfig]
    public let authenticated: Bool?

    public struct PluginAuthConfig: Codable {
        public let authField: String
        public let label: String
        public let description: String
    }
}
