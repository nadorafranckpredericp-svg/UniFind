import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var placeholder = "Search for items, people, or locations..."

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
            if !text.isEmpty {
                Button { text = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
