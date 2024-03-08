import Foundation

// Extension to handle the conversion of date strings to Date objects
extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // The ISO 8601 date format used by your JSON
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

// Custom decoder to handle the date decoding
extension JSONDecoder {
    static let iso8601Full: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        return decoder
    }()
}

extension JSONEncoder {
    static let iso8601Full: JSONEncoder = {
        let decoder = JSONEncoder()
        decoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        return decoder
    }()
}

extension Data {
    var prettyPrintedJSONString: String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: jsonObject,
                                                       options: [.prettyPrinted]),
              let prettyJSON = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
                  return nil
               }

        return String(prettyJSON)
    }
}
