import SwiftUI

struct NotificationView: View {
    @EnvironmentObject private var notificationController: NotificationController

    var body: some View {
        List {
            if notificationController.notifications.isEmpty { ContentUnavailableView("You're all caught up.", systemImage: "bell.slash") }
            ForEach(notificationController.notifications) { note in
                Button { notificationController.markRead(note.id) } label: {
                    HStack(alignment: .top, spacing: 12) {
                        ZStack { Circle().fill(iconColor(note.type).opacity(0.12)).frame(width: 42, height: 42); Image(systemName: icon(note.type)).foregroundStyle(iconColor(note.type)) }
                        VStack(alignment: .leading, spacing: 4) { HStack { Text(note.title).font(.subheadline.weight(note.isRead ? .semibold : .bold)).foregroundStyle(.primary); if !note.isRead { Circle().fill(Color.uniFindMaroon).frame(width: 7, height: 7) } }; Text(note.message).font(.caption).foregroundStyle(.secondary); Text(note.timestamp.formatted(date: .abbreviated, time: .shortened)).font(.caption2).foregroundStyle(.tertiary) }
                    }.padding(.vertical, 5)
                }.buttonStyle(.plain)
            }
        }.listStyle(.insetGrouped).navigationTitle("Notifications").navigationBarTitleDisplayMode(.inline)
    }
    private func icon(_ type: String) -> String { type == "claim" ? "checkmark.seal.fill" : type == "found" ? "shippingbox.fill" : "megaphone.fill" }
    private func iconColor(_ type: String) -> Color { type == "claim" ? .uniFindMaroon : type == "found" ? .uniFindFound : .orange }
}
