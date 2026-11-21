import SwiftUI

struct OTPVerificationView: View {
    let email: String
    @State private var code = ""
    @State private var secondsRemaining = 30
    @State private var showReset = false
    @State private var errorMessage: String?
    @State private var timer: Timer?
    @FocusState private var codeFieldFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 30)
            Image(systemName: "checkmark.shield")
                .font(.system(size: 52))
                .foregroundStyle(Color.uniFindMaroon)

            VStack(spacing: 7) {
                Text("OTP Code Verification").font(.title2.bold())
                Text("Enter the 4-digit verification code sent to\n\(email).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { index in
                    otpBox(index)
                }
            }
            .background {
                TextField("", text: $code)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($codeFieldFocused)
                    .opacity(0.01)
                    .onChange(of: code) { _, newValue in
                        code = String(newValue.filter(\.isNumber).prefix(4))
                    }
            }
            .contentShape(Rectangle())
            .onTapGesture { codeFieldFocused = true }

            VStack(spacing: 5) {
                Text("Didn't get the code? Resend")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button(secondsRemaining > 0 ? "Expires in 00:\(String(format: "%02d", secondsRemaining))" : "Resend OTP") {
                    guard secondsRemaining == 0 else { return }
                    secondsRemaining = 30
                    startTimer()
                }
                .font(.footnote.weight(.semibold))
                .disabled(secondsRemaining > 0)
            }

            if let errorMessage {
                Text(errorMessage).font(.footnote).foregroundStyle(.red)
            }

            PrimaryButton(title: "Continue") {
                if code.count == 4 {
                    errorMessage = nil
                    showReset = true
                } else {
                    errorMessage = "Please enter the 4-digit verification code."
                }
            }

            Text("Prototype tip: any 4-digit code is accepted.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(24)
        .background(Color.uniFindBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showReset) { ResetPasswordView() }
        .onAppear {
            startTimer()
            codeFieldFocused = true
        }
        .onDisappear { timer?.invalidate() }
    }

    private func otpBox(_ index: Int) -> some View {
        let character = index < code.count ? String(Array(code)[index]) : ""
        return Text(character)
            .font(.title3.bold())
            .frame(width: 50, height: 54)
            .background(.white)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(index < code.count ? Color.uniFindMaroon : Color.gray.opacity(0.25), lineWidth: 1.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { activeTimer in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                activeTimer.invalidate()
            }
        }
    }
}
