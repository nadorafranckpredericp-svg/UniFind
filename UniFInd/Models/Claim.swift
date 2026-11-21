import Foundation

struct Claim: Identifiable, Codable {
    let id: UUID
    var itemID: UUID
    var userID: String
    var claimantName: String
    var studentID: String
    var itemDescription: String
    var proofDescription: String
    var proofImageURL: String?
    var status: ClaimStatus
    var dateSubmitted: Date
}

enum ClaimStatus: String, Codable, CaseIterable {
    case pending
    case approved
    case rejected
    case returned

    var title: String { rawValue.capitalized }
}
