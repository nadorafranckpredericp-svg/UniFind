import SwiftUI

struct ClaimSuccessView: View {
    let item: LostFoundItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            ZStack { Circle().fill(Color.uniFindSuccess.opacity(0.13)).frame(width: 130, height: 130); Image(systemName: "checkmark.circle.fill").font(.system(size: 82)).foregroundStyle(Color.uniFindSuccess) }
            Text("Claim Submitted!").font(.title2.bold())
            Text("Your claim for \(item.name) has been submitted and is now under review by the Security Office.").multilineTextAlignment(.center).foregroundStyle(.secondary).padding(.horizontal, 28)
            VStack(spacing: 10) { Label("Status: Pending Verification", systemImage: "clock").font(.subheadline.weight(.semibold)); Text("You will receive a notification when the Security Office updates your claim.").font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center) }.padding(16).uniFindCard().padding(.horizontal)
            Spacer()
            Button("Done") { dismiss() }.font(.headline).frame(maxWidth: .infinity).padding(.vertical, 14).background(Color.uniFindMaroon).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 14)).padding()
        }.background(Color.uniFindBackground.ignoresSafeArea()).navigationBarBackButtonHidden(true)
    }
}
