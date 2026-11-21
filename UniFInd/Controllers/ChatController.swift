import Foundation
import Combine

final class ChatController: ObservableObject {
    @Published var messages: [ChatMessage] = [
        ChatMessage(id: UUID(), senderID: UUID(), message: "Hello! How can we help you?", timestamp: Date().addingTimeInterval(-3600), isCurrentUser: false),
        ChatMessage(id: UUID(), senderID: UUID(), message: "I believe the black wallet belongs to me.", timestamp: Date().addingTimeInterval(-3300), isCurrentUser: true),
        ChatMessage(id: UUID(), senderID: UUID(), message: "Please provide details that can verify ownership.", timestamp: Date().addingTimeInterval(-3000), isCurrentUser: false)
    ]

    func send(_ text: String, userID: UUID) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        messages.append(ChatMessage(id: UUID(), senderID: userID, message: clean, timestamp: Date(), isCurrentUser: true))
    }
}
