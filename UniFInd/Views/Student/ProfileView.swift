import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authController: AuthenticationController
    @EnvironmentObject private var claimController: ClaimController

    private var myClaimCount: Int { guard let uid = authController.currentUser?.firebaseUID else { return 0 }; return claimController.claims(for: uid).count }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 12) {
                        Circle().fill(Color.uniFindMaroon).frame(width: 78, height: 78).overlay(Text(initials).font(.title.bold()).foregroundStyle(.white))
                        Text(authController.currentUser?.name ?? "Student").font(.title3.bold())
                        Text(authController.currentUser?.email ?? "").font(.caption).foregroundStyle(.secondary)
                        HStack { stat("Items Viewed", "12"); stat("Claims", "\(myClaimCount)"); stat("Approved", "0"); stat("Returned", "0") }
                    }.frame(maxWidth: .infinity).padding(.vertical, 10)
                }
                Section("Account") {
                    NavigationLink { SettingsView() } label: { Label("Edit Profile & Settings", systemImage: "person.crop.circle") }
                    NavigationLink { MyClaimsView() } label: { Label("My Claims", systemImage: "checkmark.seal") }
                    NavigationLink { NotificationView() } label: { Label("Notifications", systemImage: "bell") }
                    Label("Help & Support", systemImage: "questionmark.circle")
                    Label("Privacy", systemImage: "hand.raised")
                    Label("Change Password", systemImage: "key")
                }
                Section { Button(role: .destructive) { authController.logout() } label: { Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right") } }
            }.navigationTitle("Profile")
            .task { if let user = authController.currentUser { await claimController.refreshClaims(for: user) } }
        }
    }
    private var initials: String { let parts = (authController.currentUser?.name ?? "Student").split(separator: " "); return parts.prefix(2).compactMap { $0.first }.map(String.init).joined() }
    private func stat(_ title: String, _ value: String) -> some View { VStack(spacing: 3) { Text(value).font(.headline).foregroundStyle(Color.uniFindMaroon); Text(title).font(.caption2).foregroundStyle(.secondary).multilineTextAlignment(.center) }.frame(maxWidth: .infinity) }
}
