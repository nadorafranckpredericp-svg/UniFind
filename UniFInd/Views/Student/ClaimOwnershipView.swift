import SwiftUI
import PhotosUI

struct ClaimOwnershipView: View {
    let item: LostFoundItem
    @EnvironmentObject private var authController: AuthenticationController
    @EnvironmentObject private var claimController: ClaimController
    @EnvironmentObject private var itemController: ItemController
    @EnvironmentObject private var notificationController: NotificationController
    @State private var fullName = ""
    @State private var studentID = ""
    @State private var itemDescription = ""
    @State private var proof = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var proofImageData: Data?
    @State private var errorMessage: String?
    @State private var submitted = false
    @State private var isSubmitting = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Claim Ownership").font(.title2.bold())
                    Text("Provide information to help the Security Office verify that this item belongs to you.").font(.subheadline).foregroundStyle(.secondary)
                }

                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14).fill(Color.uniFindMaroon.opacity(0.08))
                        if let value = item.imageName, !value.isEmpty {
                            UniFIndRemoteImage(urlString: value, fallbackSymbol: "shippingbox")
                        } else {
                            Image(systemName: "shippingbox").font(.title).foregroundStyle(Color.uniFindMaroon)
                        }
                    }
                    .frame(width: 80, height: 80).clipShape(RoundedRectangle(cornerRadius: 14))
                    VStack(alignment: .leading, spacing: 5) {
                        StatusBadgeView(status: item.status)
                        Text(item.name).font(.headline)
                        Text("\(item.location) • \(item.date.formatted(date: .abbreviated, time: .omitted))").font(.caption).foregroundStyle(.secondary)
                    }
                }.padding(14).uniFindCard()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Verification Form").font(.headline)
                    field("Full Name", text: $fullName).disabled(true)
                    field("Student ID", text: $studentID).disabled(true)
                    field("Describe the item", text: $itemDescription)
                    Text("How can you prove this item belongs to you?").font(.subheadline.weight(.semibold))
                    TextEditor(text: $proof)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color.gray.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Text("Describe unique characteristics, contents, markings, or other information only the owner would know.").font(.caption).foregroundStyle(.secondary)
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label(proofImageData == nil ? "Add Optional Proof Photo" : "Proof Photo Selected", systemImage: "photo.badge.plus")
                            .frame(maxWidth: .infinity).padding(12).background(Color.gray.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }.padding(16).uniFindCard()

                if let errorMessage {
                    Text(errorMessage).font(.footnote).foregroundStyle(.red).frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    Task { await submit() }
                } label: {
                    HStack {
                        Spacer()
                        if isSubmitting { ProgressView().tint(.white) }
                        else { Text("Submit Claim").font(.headline) }
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .background(Color.uniFindMaroon)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(isSubmitting)
            }.padding(UniFIndTheme.horizontalPadding).padding(.bottom, 30)
        }
        .background(Color.uniFindBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $submitted) { ClaimSuccessView(item: item) }
        .onChange(of: selectedPhoto) { _, newValue in
            Task { proofImageData = try? await newValue?.loadTransferable(type: Data.self) }
        }
        .onAppear {
            fullName = authController.currentUser?.name ?? ""
            studentID = authController.currentUser?.studentID ?? ""
        }
    }

    private func field(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            TextField(title, text: text).textFieldStyle(.roundedBorder)
        }
    }

    @MainActor
    private func submit() async {
        guard let user = authController.currentUser else {
            errorMessage = "Please sign in again before submitting a claim."
            return
        }
        guard !proof.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please explain how you can prove this item belongs to you."
            return
        }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        do {
            try await claimController.submitClaim(
                item: item,
                user: user,
                itemDescription: itemDescription,
                proofDescription: proof,
                proofImageData: proofImageData
            )
            await itemController.refreshItems()
            notificationController.add(title: "Claim Submitted", message: "Your claim for \(item.name) is pending Security Office review.", type: "claim")
            submitted = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
