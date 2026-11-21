import SwiftUI

struct SearchFilterView: View {
    @EnvironmentObject private var itemController: ItemController
    @State private var searchText = ""
    @State private var status = "All"
    @State private var category = "All"
    @State private var location = "All"
    @State private var selectedDate = Date()
    @State private var useDate = false
    @State private var applied = false

    private let statuses = ["All", "Lost", "Found", "Returned"]
    private let categories = ["All", "Electronics", "IDs", "Wallets", "Bags", "Keys", "Documents", "Clothing", "Accessories", "Others"]
    private let locations = ["All", "Library", "Canteen", "Gymnasium", "Computer Laboratory", "Classroom", "Security Office", "Parking Area", "Other"]

    private var results: [LostFoundItem] {
        itemController.items.filter { item in
            let textMatch = searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText) || item.location.localizedCaseInsensitiveContains(searchText) || item.category.localizedCaseInsensitiveContains(searchText)
            let statusMatch: Bool = {
                switch status {
                case "Lost": return item.reportType == .lost
                case "Found": return item.reportType == .found
                case "Returned": return item.status == .returned
                default: return true
                }
            }()
            let categoryMatch = category == "All" || item.category == category
            let locationMatch = location == "All" || item.location == location
            let dateMatch = !useDate || Calendar.current.isDate(item.date, inSameDayAs: selectedDate)
            return textMatch && statusMatch && categoryMatch && locationMatch && dateMatch
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SearchBarView(text: $searchText)

                filterSection(title: "ITEM STATUS", options: statuses, selection: $status)
                menuSection(title: "CATEGORY", selection: $category, options: categories, icon: "square.grid.2x2")
                menuSection(title: "LOCATION", selection: $location, options: locations, icon: "mappin.and.ellipse")

                VStack(alignment: .leading, spacing: 10) {
                    Text("DATE").font(.caption.bold()).foregroundStyle(.secondary)
                    Toggle("Filter by exact date", isOn: $useDate).tint(Color.uniFindMaroon)
                    if useDate {
                        DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                }
                .padding(16)
                .uniFindCard()

                HStack(spacing: 12) {
                    Button("Clear Filters") { clearFilters() }
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(.white)
                        .foregroundStyle(Color.uniFindMaroon)
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                    Button("Apply Filters") {
                        withAnimation { applied = true }
                    }
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color.uniFindMaroon)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                }

                if applied || !searchText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Search Results").font(.title3.bold())
                        if results.isEmpty {
                            ContentUnavailableView("No items found", systemImage: "magnifyingglass", description: Text("Try changing your search or filters."))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                        } else {
                            ForEach(results) { item in
                                NavigationLink {
                                    ItemDetailsView(item: item)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: symbol(for: item))
                                            .font(.title2)
                                            .frame(width: 52, height: 52)
                                            .background(Color.uniFindMaroon.opacity(0.08))
                                            .foregroundStyle(Color.uniFindMaroon)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name).font(.headline).foregroundStyle(.primary)
                                            Text("\(item.category) • \(item.location)").font(.caption).foregroundStyle(.secondary)
                                            StatusBadgeView(status: item.status)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.tertiary)
                                    }
                                    .padding(12)
                                    .uniFindCard()
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(UniFIndTheme.horizontalPadding)
            .padding(.bottom, 28)
        }
        .background(Color.uniFindBackground)
        .navigationTitle("Search & Filter")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func filterSection(title: String, options: [String], selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button(option) { selection.wrappedValue = option }
                            .font(.footnote.bold())
                            .padding(.horizontal, 13).padding(.vertical, 8)
                            .background(selection.wrappedValue == option ? Color.uniFindMaroon : Color.uniFindBackground)
                            .foregroundStyle(selection.wrappedValue == option ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .uniFindCard()
    }

    private func menuSection(title: String, selection: Binding<String>, options: [String], icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection.wrappedValue = option }
                }
            } label: {
                HStack {
                    Image(systemName: icon).foregroundStyle(Color.uniFindMaroon)
                    Text(selection.wrappedValue).foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down").font(.caption).foregroundStyle(.secondary)
                }
                .padding(13)
                .background(Color.uniFindBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .uniFindCard()
    }

    private func clearFilters() {
        searchText = ""
        status = "All"
        category = "All"
        location = "All"
        useDate = false
        applied = false
    }

    private func symbol(for item: LostFoundItem) -> String {
        switch item.category {
        case "Electronics": return "iphone"
        case "Wallets": return "wallet.pass"
        case "IDs": return "person.text.rectangle"
        case "Bags": return "backpack"
        case "Keys": return "key"
        default: return "shippingbox"
        }
    }
}
