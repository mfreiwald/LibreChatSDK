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

    public init(
        id: String,
        fileId: String,
        v: Int,
        bytes: Int,
        context: String?,
        createdAt: Date,
        filename: String,
        filepath: String,
        height: Int,
        object: String,
        source: String,
        type: String,
        updatedAt: Date,
        usage: Int,
        user: String,
        width: Int,
        message: String?
    ) {
        self.id = id
        self.fileId = fileId
        self.v = v
        self.bytes = bytes
        self.context = context
        self.createdAt = createdAt
        self.filename = filename
        self.filepath = filepath
        self.height = height
        self.object = object
        self.source = source
        self.type = type
        self.updatedAt = updatedAt
        self.usage = usage
        self.user = user
        self.width = width
        self.message = message
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
