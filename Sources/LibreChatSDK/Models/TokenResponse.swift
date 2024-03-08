import RealHTTP
import Foundation

struct TokenResponse: Decodable {
    let token: String
    let user: User
}
