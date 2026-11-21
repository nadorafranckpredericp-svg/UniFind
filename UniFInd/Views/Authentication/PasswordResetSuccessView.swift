import SwiftUI

struct PasswordResetSuccessView: View {
    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            ZStack {
                Circle().fill(Color.green.opacity(0.12)).frame(width: 120, height: 120)
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.green)
            }
            Text("Password Reset Successful!")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("Your password has been updated. You can now return to Sign In using your new password.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            NavigationLink {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            } label: {
                Text("Go to Sign In")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.uniFindMaroon)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            Spacer()
        }
        .padding(28)
        .background(Color.uniFindBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

}
