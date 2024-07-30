import Foundation
import RealHTTP

struct UserCredentials: Encodable {
    var email: String
    var password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
