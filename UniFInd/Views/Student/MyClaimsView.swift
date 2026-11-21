import SwiftUI

struct MyClaimsView: View {
    @EnvironmentObject private var authController: AuthenticationController
    @EnvironmentObject private var claimController: ClaimController
    @EnvironmentObject private var itemController: ItemController
    @State private var selected: ClaimStatus = .pending

    private var filtered: [Claim] {
        guard let uid = authController.currentUser?.firebaseUID else { return [] }
        return claimController.claims(for: uid).filter { $0.status == selected }
    }

    var body: some View {
        VStack(spacing: 12) {
            Picker("Claim Status", selection: $selected) {
                Text("Pending").tag(ClaimStatus.pending)
                Text("Approved").tag(ClaimStatus.approved)
                Text("Rejected").tag(ClaimStatus.rejected)
                Text("Returned").tag(ClaimStatus.returned)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if claimController.isLoading {
                Spacer(); ProgressView("Loading claims…"); Spacer()
            } else if filtered.isEmpty {
                ContentUnavailableView("No claims here", systemImage: "checkmark.seal", description: Text("Claims with this status will appear here."))
            } else {
                List(filtered) { claim in
                    VStack(alignment: .leading, spacing: 7) {
                        HStack {
                            Text(itemController.item(withID: claim.itemID)?.name ?? "Claimed Item").font(.headline)
                            Spacer()
                            Text(claim.status.title).font(.caption.bold()).foregroundStyle(Color.uniFindMaroon)
                        }
                        Text("Submitted \(claim.dateSubmitted.formatted(date: .abbreviated, time: .shortened))").font(.caption).foregroundStyle(.secondary)
                        Text(claim.proofDescription).font(.subheadline).lineLimit(2)
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(.insetGrouped)
                .refreshable { await refresh() }
            }
        }
        .navigationTitle("My Claims")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.uniFindBackground)
        .task { await refresh() }
    }

    @MainActor private func refresh() async {
        if let user = authController.currentUser {
            await claimController.refreshClaims(for: user)
        }
        await itemController.refreshItems()
    }
}
