import Foundation

struct NotificationItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var message: String
    var timestamp: Date
    var type: String
    var isRead: Bool
}
