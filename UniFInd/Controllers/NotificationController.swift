import Foundation
import Combine

final class NotificationController: ObservableObject {
    @Published var notifications: [NotificationItem] = [
        NotificationItem(id: UUID(), title: "New Found Item", message: "A Black Wallet was registered by the Security Office.", timestamp: Date().addingTimeInterval(-1800), type: "found", isRead: false),
        NotificationItem(id: UUID(), title: "UniFInd Announcement", message: "Remember to verify item details only with the Security Office.", timestamp: Date().addingTimeInterval(-86400), type: "announcement", isRead: true)
    ]

    func add(title: String, message: String, type: String) {
        notifications.insert(NotificationItem(id: UUID(), title: title, message: message, timestamp: Date(), type: type, isRead: false), at: 0)
    }

    func markRead(_ id: UUID) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        notifications[index].isRead = true
    }
}
