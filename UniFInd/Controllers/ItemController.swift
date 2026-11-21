import Foundation
import Combine

@MainActor
final class ItemController: ObservableObject {
    @Published var items: [LostFoundItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        Task { await refreshItems() }
    }

    func refreshItems() async {
        guard FirebaseDataService.shared.firestoreAvailable else {
            items = SampleData.items
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await FirebaseDataService.shared.fetchItems()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func registerItem(name: String, category: String, description: String, location: String,
                      date: Date, reportType: ReportType, imageData: Data?) async throws {
        var imageURL: String?
        if let imageData { imageURL = try await CloudinaryService.shared.uploadImage(data: imageData) }
        let item = LostFoundItem(id: UUID(), name: name, category: category, description: description,
            location: location, date: date,
            status: reportType == .lost ? .lost : .availableForClaim,
            reportType: reportType, imageName: imageURL, registeredBy: "University Security Office",
            isInCustody: reportType == .found, ownerName: nil)
        try await FirebaseDataService.shared.createItem(item)
        await refreshItems()
    }

    func updateStatus(itemID: UUID, status: ItemStatus) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].status = status
    }

    func item(withID id: UUID) -> LostFoundItem? { items.first { $0.id == id } }
}
