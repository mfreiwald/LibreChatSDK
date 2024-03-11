import Foundation

public struct ChatFile: Codable {
    public let id: String
    public let fileId: String
    public let v: Int
    public let bytes: Int
    public let context: String?
    public let createdAt: Date
    public let filename: String
    public let filepath: String
    public let height: Int
    public let object: String
    public let source: String
    public let type: String
    public let updatedAt: Date
    public let usage: Int
    public let user: String
    public let width: Int
    public let message: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fileId = "file_id"
        case v = "__v"
        case bytes, context, createdAt, filename, filepath, height, object, source, type, updatedAt, usage, user, width, message
    }
}

public struct DeleteFileRequest: Codable {
    public let files: [File]

    public init(files: [File]) {
        self.files = files
    }

    public struct File: Codable {
        public let fileId: String
        public let filepath: String
        public let source: String

        public init(fileId: String, filepath: String, source: String) {
            self.fileId = fileId
            self.filepath = filepath
            self.source = source
        }

        enum CodingKeys: String, CodingKey {
            case fileId = "file_id"
            case filepath, source
        }
    }
}
