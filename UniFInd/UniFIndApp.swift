import SwiftUI

@main
struct UniFIndApp: App {
    @StateObject private var authController = AuthenticationController()
    @StateObject private var itemController = ItemController()
    @StateObject private var claimController = ClaimController()
    @StateObject private var chatController = ChatController()
    @StateObject private var notificationController = NotificationController()

    init() {
        FirebaseBootstrap.configureIfPossible()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authController)
                .environmentObject(itemController)
                .environmentObject(claimController)
                .environmentObject(chatController)
                .environmentObject(notificationController)
                .tint(.uniFindMaroon)
        }
    }
}
