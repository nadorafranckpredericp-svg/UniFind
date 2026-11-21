import SwiftUI

struct AdminPlaceholderView: View {
    let title: String
    let icon: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Image(systemName: icon).font(.system(size: 44)).foregroundStyle(Color.uniFindMaroon)
                Text(title).font(.title2.bold())
                Text("This module will be connected in the next development phase.").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            .padding(30)
            .navigationTitle(title)
            .background(Color.uniFindBackground)
        }
    }
}

struct AdminReviewView: View {
    @EnvironmentObject private var claimController: ClaimController
    @EnvironmentObject private var itemController: ItemController
    @State private var selectedStatus: ClaimStatus = .pending
    @State private var actionError: String?
    @State private var workingClaimID: UUID?

    private var displayedClaims: [Claim] {
        claimController.claims.filter { $0.status == selectedStatus }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Picker("Status", selection: $selectedStatus) {
                    Text("Pending").tag(ClaimStatus.pending)
                    Text("Approved").tag(ClaimStatus.approved)
                    Text("Rejected").tag(ClaimStatus.rejected)
                    Text("Returned").tag(ClaimStatus.returned)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if claimController.isLoading {
                    Spacer(); ProgressView("Loading claims…"); Spacer()
                } else if displayedClaims.isEmpty {
                    ContentUnavailableView("No \(selectedStatus.title.lowercased()) claims", systemImage: "checkmark.circle", description: Text("Claims will appear here when students submit them."))
                } else {
                    List(displayedClaims) { claim in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(itemController.item(withID: claim.itemID)?.name ?? "Item Claim").font(.headline)
                                    Text("\(claim.claimantName) • \(claim.studentID)").font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(claim.status.title).font(.caption.bold()).foregroundStyle(Color.uniFindMaroon)
                            }

                            if !claim.itemDescription.isEmpty {
                                Text("Item description: \(claim.itemDescription)").font(.subheadline)
                            }
                            Text("Proof: \(claim.proofDescription)").font(.subheadline)

                            if let proofURL = claim.proofImageURL, !proofURL.isEmpty {
                                UniFIndRemoteImage(urlString: proofURL, fallbackSymbol: "photo")
                                    .frame(height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            Text("Submitted \(claim.dateSubmitted.formatted(date: .abbreviated, time: .shortened))").font(.caption).foregroundStyle(.secondary)

                            if claim.status == .pending {
                                HStack(spacing: 10) {
                                    actionButton("Reject", systemImage: "xmark", claim: claim, status: .rejected, filled: false)
                                    actionButton("Approve", systemImage: "checkmark", claim: claim, status: .approved, filled: true)
                                }
                            } else if claim.status == .approved {
                                actionButton("Mark Item as Returned", systemImage: "checkmark.seal.fill", claim: claim, status: .returned, filled: true)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listStyle(.insetGrouped)
                    .refreshable { await refresh() }
                }

                if let actionError {
                    Text(actionError).font(.footnote).foregroundStyle(.red).padding(.horizontal)
                }
            }
            .background(Color.uniFindBackground)
            .navigationTitle("Claim Review")
            .task { await refresh() }
        }
    }

    private func actionButton(_ title: String, systemImage: String, claim: Claim, status: ClaimStatus, filled: Bool) -> some View {
        Button {
            Task { await update(claim, to: status) }
        } label: {
            HStack {
                if workingClaimID == claim.id { ProgressView().tint(filled ? .white : Color.uniFindMaroon) }
                else { Image(systemName: systemImage) }
                Text(title).font(.subheadline.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(filled ? Color.uniFindMaroon : Color.white)
            .foregroundStyle(filled ? Color.white : Color.uniFindMaroon)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.uniFindMaroon.opacity(filled ? 0 : 0.35)))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(workingClaimID != nil)
    }

    @MainActor private func refresh() async {
        await claimController.refreshAllClaims()
        await itemController.refreshItems()
    }

    @MainActor private func update(_ claim: Claim, to status: ClaimStatus) async {
        workingClaimID = claim.id
        actionError = nil
        defer { workingClaimID = nil }
        do {
            try await claimController.updateClaim(claim, status: status)
            await itemController.refreshItems()
        } catch {
            actionError = error.localizedDescription
        }
    }
}
