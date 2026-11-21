import SwiftUI

struct AdminHomeView: View {
    @EnvironmentObject private var authController: AuthenticationController
    @EnvironmentObject private var itemController: ItemController

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Circle().fill(Color.uniFindMaroon).frame(width: 44, height: 44).overlay(Image(systemName: "shield.fill").foregroundStyle(.white))
                        VStack(alignment: .leading) { Text("Hi, Admin").font(.headline); Text("Security Office").font(.caption).foregroundStyle(.secondary) }
                        Spacer()
                        Button { authController.logout() } label: { Image(systemName: "rectangle.portrait.and.arrow.right") }
                    }
                    Text("UniFInd Dashboard").font(.title.bold())
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        statCard("Lost Items", value: itemController.items.filter { $0.reportType == .lost }.count, icon: "exclamationmark.circle")
                        statCard("Found Items", value: itemController.items.filter { $0.reportType == .found }.count, icon: "checkmark.circle")
                        statCard("Pending Claims", value: 1, icon: "clock")
                        statCard("Returned", value: 0, icon: "arrow.uturn.backward.circle")
                    }
                    Text("Quick Actions").font(.title3.bold())
                    VStack(spacing: 12) {
                        adminAction("Register Lost Item", "Register an item reported missing on campus.", "exclamationmark.triangle")
                        adminAction("Register Found Item", "Register an item recovered and submitted to the Security Office.", "shippingbox.and.arrow.backward")
                    }
                }
                .padding(UniFIndTheme.horizontalPadding)
            }
            .background(Color.uniFindBackground)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func statCard(_ title: String, value: Int, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).foregroundStyle(Color.uniFindMaroon)
            Text("\(value)").font(.title.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(16).uniFindCard()
    }

    private func adminAction(_ title: String, _ subtitle: String, _ icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.title2).foregroundStyle(Color.uniFindMaroon).frame(width: 42)
            VStack(alignment: .leading, spacing: 4) { Text(title).font(.headline); Text(subtitle).font(.caption).foregroundStyle(.secondary) }
            Spacer(); Image(systemName: "chevron.right").foregroundStyle(.tertiary)
        }
        .padding(16).uniFindCard()
    }
}
