import SwiftUI

struct ChatView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink { ChatConversationView() } label: {
                        HStack(spacing: 12) {
                            ZStack { Circle().fill(Color.uniFindMaroon).frame(width: 50, height: 50); Image(systemName: "shield.fill").foregroundStyle(.white) }
                            VStack(alignment: .leading, spacing: 4) { Text("UniFInd Security Office").font(.headline); Text("Please provide details that can verify ownership.").font(.caption).foregroundStyle(.secondary).lineLimit(1) }
                            Spacer(); VStack(alignment: .trailing, spacing: 7) { Text("Now").font(.caption2).foregroundStyle(.secondary); Text("1").font(.caption2.bold()).foregroundStyle(.white).padding(6).background(Color.uniFindMaroon).clipShape(Circle()) }
                        }.padding(.vertical, 6)
                    }
                }
            }.listStyle(.insetGrouped).navigationTitle("Chat").searchable(text: .constant(""), prompt: "Search conversations")
        }
    }
}
