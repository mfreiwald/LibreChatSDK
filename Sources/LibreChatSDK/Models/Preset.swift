import Foundation

public struct Preset: Codable {
    public let _id: String
    public let user: String
    public let presetId: String
    public let __v: Int
    public let agentOptions: AgentOptions?
    public let chatGptLabel: String
    public let createdAt: Date
    public let endpoint: String
    public let examples: [String]?
    public let frequency_penalty: Double
    public let imageDetail: String
    public let model: String
    public let presence_penalty: Double
    public let promptPrefix: String
    public let resendImages: Bool
    public let temperature: Double
    public let title: String
    public let top_p: Double
    public let updatedAt: Date
}

typealias Presets = [Preset]
