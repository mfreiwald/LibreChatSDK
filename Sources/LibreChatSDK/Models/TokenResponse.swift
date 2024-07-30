import RealHTTP
import Foundation

struct TokenResponse: Decodable {
    let token: String
    let user: User

    public init(token: String, user: User) {
        self.token = token
        self.user = user
    }
}
