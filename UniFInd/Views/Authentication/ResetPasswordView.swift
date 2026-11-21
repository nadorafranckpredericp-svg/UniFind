import SwiftUI

struct ResetPasswordView: View {
    @EnvironmentObject private var authController: AuthenticationController
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showSuccess = false

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 35)
            Image(systemName: "key.horizontal.fill")
                .font(.system(size: 46))
                .foregroundStyle(Color.uniFindMaroon)

            VStack(spacing: 7) {
                Text("Create new password").font(.title2.bold())
                Text("Create a strong password with at least 6 characters.")
                    .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }

            passwordField("New Password", text: $password)
            passwordField("Confirm New Password", text: $confirmPassword)

            if let error = authController.errorMessage {
                Text(error).font(.footnote).foregroundStyle(.red).frame(maxWidth: .infinity, alignment: .leading)
            }

            PrimaryButton(title: "Continue") {
                if authController.validateNewPassword(password, confirmPassword: confirmPassword) {
                    showSuccess = true
                }
            }
            Spacer()
        }
        .padding(24)
        .background(Color.uniFindBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showSuccess) { PasswordResetSuccessView() }
        .onAppear { authController.clearError() }
    }

    private func passwordField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            HStack {
                Image(systemName: "lock").foregroundStyle(.secondary)
                Group {
                    if showPassword { TextField(title, text: text) }
                    else { SecureField(title, text: text) }
                }
                Button { showPassword.toggle() } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye").foregroundStyle(.secondary)
                }
            }
            .padding(14).background(.white).clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
