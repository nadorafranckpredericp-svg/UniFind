import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("Account") { Label("Edit Profile", systemImage: "person"); Label("Security", systemImage: "lock"); NavigationLink { NotificationView() } label: { Label("Notifications", systemImage: "bell") }; Label("Privacy", systemImage: "hand.raised") }
            Section("Support") { Label("Help & Support", systemImage: "questionmark.circle"); Label("Terms and Policies", systemImage: "doc.text") }
        }.navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
    }
}
