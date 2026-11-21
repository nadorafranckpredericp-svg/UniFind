import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var itemController: ItemController
    @EnvironmentObject private var authController: AuthenticationController
    @State private var searchText = ""

    private var recentItemsList: [LostFoundItem] {
        Array(itemController.items.sorted { $0.date > $1.date }.prefix(8))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    SearchBarView(text: $searchText)
                    hero
                    quickActions
                    recentItems
                }
                .padding(.horizontal, UniFIndTheme.horizontalPadding)
                .padding(.vertical, 12)
            }
            .background(Color.uniFindBackground)
            .toolbar(.hidden, for: .navigationBar)
            .task { await itemController.refreshItems() }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Circle().fill(Color.uniFindMaroon).frame(width: 44, height: 44)
                .overlay(Text(initials).foregroundStyle(.white).font(.subheadline.bold()))
            VStack(alignment: .leading, spacing: 2) {
                Text("Hi, \(firstName)!").font(.headline)
                Text("Find what matters.").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            NavigationLink { NotificationView() } label: {
                Image(systemName: "bell").font(.title3).foregroundStyle(.primary)
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .leading) {
            LinearGradient(colors: [.uniFindMaroon, .uniFindMaroon.opacity(0.88), .uniFindMaroon.opacity(0.34)], startPoint: .leading, endPoint: .trailing)
            Image(systemName: "building.columns.fill")
                .resizable().scaledToFit().foregroundStyle(.white.opacity(0.16)).padding(22).frame(maxWidth: .infinity, alignment: .trailing)
            VStack(alignment: .leading, spacing: 10) {
                Text("Looking for something you've lost?").font(.title3.bold()).foregroundStyle(.white)
                Text("Search official campus records and find your belongings.").font(.footnote).foregroundStyle(.white.opacity(0.86))
                NavigationLink { ExploreView() } label: {
                    Text("Find an Item").font(.footnote.bold()).padding(.horizontal, 14).padding(.vertical, 9).background(.white).foregroundStyle(Color.uniFindMaroon).clipShape(Capsule())
                }
            }
            .padding(20).frame(maxWidth: 260, alignment: .leading)
        }
        .frame(height: 178)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            NavigationLink { ExploreView() } label: {
                quickCard(icon: "square.grid.2x2", title: "Explore Items", subtitle: "Browse official records")
            }.buttonStyle(.plain)
            quickCard(icon: "megaphone", title: "Announcements", subtitle: "Campus updates")
        }
    }

    private func quickCard(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).font(.title2).foregroundStyle(Color.uniFindMaroon)
            Text(title).font(.subheadline.bold())
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(16).uniFindCard()
    }

    private var recentItems: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Items").font(.title3.bold())
                Spacer()
                NavigationLink { ExploreView() } label: {
                    Text("View all ›").font(.footnote).foregroundStyle(Color.uniFindMaroon)
                }
            }
            if recentItemsList.isEmpty {
                Text("No registered items yet.").font(.subheadline).foregroundStyle(.secondary).padding(.vertical, 12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(recentItemsList) { item in
                            NavigationLink { ItemDetailsView(item: item) } label: {
                                ItemCardView(item: item).frame(width: 175)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var firstName: String {
        authController.currentUser?.name.split(separator: " ").first.map(String.init) ?? "Student"
    }

    private var initials: String {
        let parts = (authController.currentUser?.name ?? "Student").split(separator: " ")
        return parts.prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
    }
}
