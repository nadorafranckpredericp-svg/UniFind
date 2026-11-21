import SwiftUI

struct ItemCardView: View {
    let item: LostFoundItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(Color.gray.opacity(0.12))
                if let value = item.imageName, !value.isEmpty {
                    UniFIndRemoteImage(urlString: value, fallbackSymbol: symbol)
                } else {
                    fallback
                }
            }
            .frame(height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            StatusBadgeView(status: item.status)
            Text(item.name).font(.headline).lineLimit(1)
            Label(item.location, systemImage: "mappin.and.ellipse").font(.caption).foregroundStyle(.secondary)
        }
        .padding(12)
        .uniFindCard()
    }

    private var fallback: some View {
        Image(systemName: symbol).font(.system(size: 40)).foregroundStyle(Color.uniFindMaroon.opacity(0.75))
    }

    private var symbol: String {
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

struct UniFIndRemoteImage: View {
    let urlString: String
    var fallbackSymbol: String = "photo"

    private var imageURL: URL? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        let secure = trimmed.hasPrefix("http://") ? trimmed.replacingOccurrences(of: "http://", with: "https://") : trimmed
        return URL(string: secure) ?? URL(string: secure.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
    }

    var body: some View {
        if let imageURL {
            AsyncImage(url: imageURL, transaction: Transaction(animation: .easeInOut(duration: 0.2))) { phase in
                switch phase {
                case .empty:
                    ZStack { Color.gray.opacity(0.06); ProgressView() }
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    ZStack {
                        Color.gray.opacity(0.08)
                        Image(systemName: fallbackSymbol).font(.system(size: 36)).foregroundStyle(Color.uniFindMaroon.opacity(0.7))
                    }
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            ZStack {
                Color.gray.opacity(0.08)
                Image(systemName: fallbackSymbol).font(.system(size: 36)).foregroundStyle(Color.uniFindMaroon.opacity(0.7))
            }
        }
    }
}
