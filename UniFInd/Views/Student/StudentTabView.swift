import SwiftUI

struct StudentTabView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Home", systemImage: "house") }
            ExploreView().tabItem { Label("Explore", systemImage: "square.grid.2x2") }
            ChatView().tabItem { Label("Chat", systemImage: "bubble.left") }
            ProfileView().tabItem { Label("Profile", systemImage: "person.circle") }
        }
    }
}
