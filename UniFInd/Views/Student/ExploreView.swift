import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var itemController: ItemController
    @State private var searchText = ""
    @State private var selectedFilter = "All Items"
    private let filters = ["All Items", "Lost", "Found", "Recent"]
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var filtered: [LostFoundItem] {
        itemController.items
            .filter { item in
                let matchesText = searchText.isEmpty ||
                    item.name.localizedCaseInsensitiveContains(searchText) ||
                    item.category.localizedCaseInsensitiveContains(searchText) ||
                    item.location.localizedCaseInsensitiveContains(searchText)
                let matchesFilter: Bool
                switch selectedFilter {
                case "Lost": matchesFilter = item.reportType == .lost
                case "Found": matchesFilter = item.reportType == .found
                default: matchesFilter = true
                }
                return matchesText && matchesFilter
            }
            .sorted { selectedFilter == "Recent" ? $0.date > $1.date : false }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Find officially registered lost and found items around the campus.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    SearchBarView(text: $searchText)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(filters, id: \.self) { title in
                                filterChip(title, active: selectedFilter == title) {
                                    withAnimation(.easeInOut(duration: 0.18)) { selectedFilter = title }
                                }
                            }
                        }
                    }

                    if filtered.isEmpty {
                        ContentUnavailableView(
                            "No items found",
                            systemImage: "magnifyingglass",
                            description: Text("Try changing your search or filters.")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(filtered) { item in
                                NavigationLink {
                                    ItemDetailsView(item: item)
                                } label: {
                                    ItemCardView(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(UniFIndTheme.horizontalPadding)
                .padding(.bottom, 24)
            }
            .background(Color.uniFindBackground)
            .navigationTitle("Explore")
            .refreshable { await itemController.refreshItems() }
            .task { await itemController.refreshItems() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SearchFilterView()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(Color.uniFindMaroon)
                    }
                    .accessibilityLabel("Search and filter lost and found items")
                }
            }
        }
    }

    private func filterChip(_ title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.bold())
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(active ? Color.uniFindMaroon : .white)
                .foregroundStyle(active ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
