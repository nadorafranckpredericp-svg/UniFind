import SwiftUI

struct ChatConversationView: View {
    @EnvironmentObject private var authController: AuthenticationController
    @EnvironmentObject private var chatController: ChatController
    @State private var draft = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatController.messages) { message in
                            HStack { if message.isCurrentUser { Spacer(minLength: 60) }; Text(message.message).font(.subheadline).padding(.horizontal, 14).padding(.vertical, 10).background(message.isCurrentUser ? Color.uniFindMaroon : Color.gray.opacity(0.12)).foregroundStyle(message.isCurrentUser ? .white : .primary).clipShape(RoundedRectangle(cornerRadius: 16)); if !message.isCurrentUser { Spacer(minLength: 60) } }.id(message.id)
                        }
                    }.padding()
                }.onChange(of: chatController.messages.count) { _, _ in if let id = chatController.messages.last?.id { withAnimation { proxy.scrollTo(id, anchor: .bottom) } } }
            }
            HStack(spacing: 10) { Button(action: {}) { Image(systemName: "paperclip") }; TextField("Send message...", text: $draft).textFieldStyle(.roundedBorder); Button { if let id = authController.currentUser?.id { chatController.send(draft, userID: id); draft = "" } } label: { Image(systemName: "arrow.up.circle.fill").font(.title2).foregroundStyle(Color.uniFindMaroon) } }.padding().background(.bar)
        }
        .navigationTitle("UniFInd Security Office").navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .principal) { VStack(spacing: 1) { Text("UniFInd Security Office").font(.subheadline.bold()); Text("Online").font(.caption2).foregroundStyle(.green) } } }
    }
}
