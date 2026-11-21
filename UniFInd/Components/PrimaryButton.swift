import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title).font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(Color.uniFindMaroon)
        .clipShape(RoundedRectangle(cornerRadius: UniFIndTheme.buttonRadius, style: .continuous))
    }
}
