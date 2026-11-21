import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var firebaseUID: String?
    var name: String
    var email: String
    var studentID: String
    var role: UserRole
}

enum UserRole: String, Codable {
    case student
    case admin
}
