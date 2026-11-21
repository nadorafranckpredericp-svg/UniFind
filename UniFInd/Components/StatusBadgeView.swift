import SwiftUI

struct StatusBadgeView: View {
    let status: ItemStatus

    var body: some View {
        Text(status.title.uppercased())
            .font(.caption2.bold())
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .foregroundStyle(color)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private var color: Color {
        switch status {
        case .lost: return .uniFindLost
        case .found, .availableForClaim, .claimApproved, .returned: return .uniFindFound
        case .claimPending, .unclaimed: return .uniFindWarning
        case .archived: return .secondary
        }
    }
}
