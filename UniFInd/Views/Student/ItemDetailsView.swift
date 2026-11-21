import SwiftUI

struct ItemDetailsView: View {
    let item: LostFoundItem
    @EnvironmentObject private var itemController: ItemController

    private var currentItem: LostFoundItem { itemController.item(withID: item.id) ?? item }
    private var canClaim: Bool { currentItem.reportType == .found && (currentItem.status == .found || currentItem.status == .availableForClaim) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22).fill(Color.gray.opacity(0.10))
                    if let value = currentItem.imageName, !value.isEmpty {
                        UniFIndRemoteImage(urlString: value, fallbackSymbol: symbol)
                    } else {
                        Image(systemName: symbol).font(.system(size: 76, weight: .light)).foregroundStyle(Color.uniFindMaroon.opacity(0.78))
                    }
                }.frame(height: 230).clipShape(RoundedRectangle(cornerRadius: 22))

                VStack(alignment: .leading, spacing: 9) {
                    StatusBadgeView(status: currentItem.status)
                    Text(currentItem.name).font(.title2.bold())
                    Text(currentItem.category).font(.subheadline).foregroundStyle(.secondary)
                }

                VStack(spacing: 12) {
                    infoRow("Location", value: currentItem.location, icon: "mappin.and.ellipse")
                    Divider()
                    infoRow("Date", value: currentItem.date.formatted(date: .abbreviated, time: .omitted), icon: "calendar")
                    Divider()
                    infoRow("Record type", value: currentItem.reportType == .lost ? "Lost Item" : "Found Item", icon: currentItem.reportType == .lost ? "exclamationmark.triangle" : "checkmark.circle")
                }.padding(16).uniFindCard()

                VStack(alignment: .leading, spacing: 9) {
                    Text("Description").font(.headline)
                    Text(currentItem.description).font(.subheadline).foregroundStyle(.secondary)
                }.padding(16).uniFindCard()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Official Record").font(.headline)
                    infoRow("Registered by", value: currentItem.registeredBy, icon: "checkmark.seal")
                    infoRow("Current status", value: currentItem.status.title, icon: "circlebadge")
                    if currentItem.reportType == .found { infoRow("Custody", value: currentItem.isInCustody ? "Security Office" : "Pending transfer", icon: "building.2") }
                }.padding(16).uniFindCard()

                if currentItem.status == .returned {
                    Label("Item Returned", systemImage: "checkmark.circle.fill").font(.headline).foregroundStyle(.green).frame(maxWidth: .infinity).padding(.vertical, 14).background(Color.green.opacity(0.10)).clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    if canClaim {
                        NavigationLink { ClaimOwnershipView(item: currentItem) } label: {
                            Text("Claim Ownership").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14).background(Color.uniFindMaroon).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    NavigationLink { ChatConversationView() } label: {
                        Text("Message Security Office").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14).background(.white).foregroundStyle(Color.uniFindMaroon).overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.uniFindMaroon.opacity(0.25)))
                    }
                }
            }.padding(UniFIndTheme.horizontalPadding).padding(.bottom, 28)
        }
        .background(Color.uniFindBackground)
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoRow(_ title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) { Image(systemName: icon).foregroundStyle(Color.uniFindMaroon).frame(width: 24); VStack(alignment: .leading, spacing: 2) { Text(title).font(.caption).foregroundStyle(.secondary); Text(value).font(.subheadline.weight(.semibold)) }; Spacer() }
    }
    private var symbol: String { switch currentItem.category { case "Electronics": return "iphone"; case "Wallets": return "wallet.pass"; case "IDs": return "person.text.rectangle"; case "Bags": return "backpack"; case "Keys": return "key"; default: return "shippingbox" } }
}
