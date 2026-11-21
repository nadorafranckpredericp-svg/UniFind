import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject private var authController: AuthenticationController
    @State private var email = ""
    @State private var showOTP = false

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 35)

            ZStack {
                Circle().fill(Color.uniFindMaroon.opacity(0.10)).frame(width: 88, height: 88)
                Image(systemName: "lock.rotation")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(Color.uniFindMaroon)
            }

            VStack(spacing: 7) {
                Text("Reset your Password").font(.title2.bold())
                Text("Enter your university email and we'll send a verification code to help reset your password.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("University Email").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                HStack {
                    Image(systemName: "envelope").foregroundStyle(.secondary)
                    TextField("student@mseuf.edu.ph", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if let error = authController.errorMessage {
                Text(error).font(.footnote).foregroundStyle(.red).frame(maxWidth: .infinity, alignment: .leading)
            }

            PrimaryButton(title: "Continue") {
                if authController.validateResetEmail(email) { showOTP = true }
            }

            Spacer()
        }
        .padding(24)
        .background(Color.uniFindBackground.ignoresSafeArea())
        .navigationTitle("Forgot Password")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showOTP) {
            OTPVerificationView(email: email)
        }
        .onAppear { authController.clearError() }
    }
}
