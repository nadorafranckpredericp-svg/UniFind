import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var authController: AuthenticationController
    @State private var name = ""
    @State private var studentID = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var agreed = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Create an Account")
                        .font(.largeTitle.bold())
                    Text("Join UniFInd and stay connected to official campus Lost & Found records.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 14) {
                    field("Full Name", text: $name, icon: "person")
                    field("Student ID", text: $studentID, icon: "person.text.rectangle")
                    field("University Email", text: $email, icon: "envelope", keyboard: .emailAddress)

                    secureField("Password", text: $password)
                    secureField("Confirm Password", text: $confirmPassword)

                    Button {
                        agreed.toggle()
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: agreed ? "checkmark.square.fill" : "square")
                                .foregroundStyle(agreed ? Color.uniFindMaroon : .secondary)
                            Text("I have read and agree to the User Agreement and Privacy Policy.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)

                    if let error = authController.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    PrimaryButton(title: "Create Account") {
                        guard agreed else {
                            authController.errorMessage = "Please accept the agreement to continue."
                            return
                        }
                        _ = authController.signUp(
                            name: name,
                            studentID: studentID,
                            email: email,
                            password: password,
                            confirmPassword: confirmPassword
                        )
                    }
                }
                .padding(18)
                .uniFindCard()
            }
            .padding(UniFIndTheme.horizontalPadding)
            .padding(.bottom, 30)
        }
        .background(Color.uniFindBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { authController.clearError() }
    }

    private func field(_ title: String, text: Binding<String>, icon: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            HStack {
                Image(systemName: icon).foregroundStyle(.secondary).frame(width: 20)
                TextField(title, text: text)
                    .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                    .keyboardType(keyboard)
            }
            .padding(13)
            .background(Color.uniFindBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func secureField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            HStack {
                Image(systemName: "lock").foregroundStyle(.secondary).frame(width: 20)
                Group {
                    if showPassword { TextField(title, text: text) }
                    else { SecureField(title, text: text) }
                }
                Button { showPassword.toggle() } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(13)
            .background(Color.uniFindBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
