import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    var senderID: UUID
    var message: String
    var timestamp: Date
    var isCurrentUser: Bool
}
