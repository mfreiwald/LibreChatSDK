import Foundation

public typealias Endpoints = [String: EndpointInfo]

public struct EndpointInfo: Codable {
    public let plugins: [String: String]?
    public let availableAgents: [String]?
    public let userProvide: Bool?
    public let azure: Bool?
    public let order: Int
    public let type: String?
    public let userProvideURL: Bool?
    public let modelDisplayLabel: String?

    public init(
        plugins: [String : String]?,
        availableAgents: [String]?,
        userProvide: Bool?,
        azure: Bool?,
        order: Int,
        type: String?,
        userProvideURL: Bool?,
        modelDisplayLabel: String?
    ) {
        self.plugins = plugins
        self.availableAgents = availableAgents
        self.userProvide = userProvide
        self.azure = azure
        self.order = order
        self.type = type
        self.userProvideURL = userProvideURL
        self.modelDisplayLabel = modelDisplayLabel
    }
}

public extension EndpointInfo {
    static func make(order: Int, userProvide: Bool = true) -> Self {
        .init(plugins: nil, availableAgents: nil, userProvide: userProvide, azure: nil, order: order, type: nil, userProvideURL: nil, modelDisplayLabel: nil)
    }
}

/*
public struct Endpoints: Codable {
    public let azureOpenAI: AzureOpenAISetting?
    public let gptPlugins: GPTPluginInfo?

    public struct AzureOpenAISetting: Codable {
        public let userProvide: Bool
        public let order: Int
    }

    public struct GPTPluginInfo: Codable {
        public let plugins: [String: String]
        public let availableAgents: [String]
        public let userProvide: Bool
        public let azure: Bool
        public let order: Int
    }
}
*/
