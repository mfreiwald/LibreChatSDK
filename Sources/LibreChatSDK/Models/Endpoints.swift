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
