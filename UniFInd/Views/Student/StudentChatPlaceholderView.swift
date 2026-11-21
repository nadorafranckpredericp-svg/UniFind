import SwiftUI

struct StudentChatPlaceholderView: View {
    var body: some View {
        NavigationStack {
            List {
                HStack(spacing: 14) {
                    Circle().fill(Color.uniFindMaroon.opacity(0.12)).frame(width: 48, height: 48).overlay(Image(systemName: "shield.fill").foregroundStyle(Color.uniFindMaroon))
                    VStack(alignment: .leading) { Text("UniFInd Security Office").font(.headline); Text("Hello! How can we help you?").font(.subheadline).foregroundStyle(.secondary) }
                    Spacer()
                }
            }
            .navigationTitle("Chat")
        }
    }
}
