import Foundation
import Combine

@MainActor
final class ClaimController: ObservableObject {
    @Published var claims: [Claim] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func refreshClaims(for user: User) async {
        guard let uid = user.firebaseUID, !uid.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            claims = try await FirebaseDataService.shared.fetchClaims(userID: uid)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshAllClaims() async {
        isLoading = true
        defer { isLoading = false }
        do {
            claims = try await FirebaseDataService.shared.fetchAllClaims()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func submitClaim(item: LostFoundItem, user: User, itemDescription: String, proofDescription: String, proofImageData: Data?) async throws {
        guard let uid = user.firebaseUID, !uid.isEmpty else {
            throw FirebaseDataServiceError.missingAuthenticatedUser
        }
        let proof = proofDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !proof.isEmpty else { throw FirebaseDataServiceError.invalidClaim }

        var proofImageURL: String?
        if let proofImageData {
            proofImageURL = try await CloudinaryService.shared.uploadImage(data: proofImageData)
        }

        let claim = Claim(
            id: UUID(),
            itemID: item.id,
            userID: uid,
            claimantName: user.name,
            studentID: user.studentID,
            itemDescription: itemDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            proofDescription: proof,
            proofImageURL: proofImageURL,
            status: .pending,
            dateSubmitted: Date()
        )
        try await FirebaseDataService.shared.createClaim(claim)
        try await FirebaseDataService.shared.updateItemStatus(itemID: item.id, status: .claimPending)
        await refreshClaims(for: user)
    }

    func updateClaim(_ claim: Claim, status: ClaimStatus) async throws {
        try await FirebaseDataService.shared.updateClaimStatus(claimID: claim.id, status: status)
        let itemStatus: ItemStatus
        switch status {
        case .pending: itemStatus = .claimPending
        case .approved: itemStatus = .claimApproved
        case .rejected: itemStatus = .availableForClaim
        case .returned: itemStatus = .returned
        }
        try await FirebaseDataService.shared.updateItemStatus(itemID: claim.itemID, status: itemStatus)
        await refreshAllClaims()
    }

    func claims(for userID: String) -> [Claim] {
        claims.filter { $0.userID == userID }
    }
}
