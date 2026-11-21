import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authController: AuthenticationController

    var body: some View {
        Group {
            if let user = authController.currentUser {
                if user.role == .admin {
                    AdminTabView()
                } else {
                    StudentTabView()
                }
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: authController.currentUser?.id)
    }
}
