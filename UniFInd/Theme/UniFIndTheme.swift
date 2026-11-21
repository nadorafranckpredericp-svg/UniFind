import SwiftUI

enum UniFIndTheme {
    static let cardRadius: CGFloat = 18
    static let buttonRadius: CGFloat = 14
    static let horizontalPadding: CGFloat = 20
}

struct UniFIndCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: UniFIndTheme.cardRadius, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, y: 5)
    }
}

extension View {
    func uniFindCard() -> some View { modifier(UniFIndCardModifier()) }
}
