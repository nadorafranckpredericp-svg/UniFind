import SwiftUI

struct AdminTabView: View {
    var body: some View {
        TabView {
            AdminHomeView().tabItem { Label("Home", systemImage: "house") }
            AdminReviewView().tabItem { Label("Review", systemImage: "checkmark.circle") }
            AdminRegisterView().tabItem { Label("Register", systemImage: "plus.square") }
            AdminPlaceholderView(title: "Chat", icon: "bubble.left").tabItem { Label("Chat", systemImage: "bubble.left") }
            AdminPlaceholderView(title: "Users", icon: "person.2").tabItem { Label("Users", systemImage: "person.2") }
        }
    }
}
