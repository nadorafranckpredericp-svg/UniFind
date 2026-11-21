import Foundation

struct LostFoundItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: String
    var description: String
    var location: String
    var date: Date
    var status: ItemStatus
    var reportType: ReportType
    var imageName: String?
    var registeredBy: String
    var isInCustody: Bool
    var ownerName: String?
}

enum ItemStatus: String, Codable, CaseIterable {
    case lost
    case found
    case availableForClaim
    case claimPending
    case claimApproved
    case returned
    case unclaimed
    case archived

    var title: String {
        switch self {
        case .lost: return "Lost"
        case .found: return "Found"
        case .availableForClaim: return "Available for Claim"
        case .claimPending: return "Claim Pending"
        case .claimApproved: return "Claim Approved"
        case .returned: return "Returned"
        case .unclaimed: return "Unclaimed"
        case .archived: return "Archived"
        }
    }
}

enum ReportType: String, Codable, CaseIterable {
    case lost
    case found
}
