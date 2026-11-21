import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authController: AuthenticationController
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var path: [AppRoute] = []
    @State private var showAdminLogin = false
    @State private var adminEmail = ""
    @State private var adminPassword = ""

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.uniFindBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 50)

                        VStack(spacing: 12) {
                            ZStack {
                                Circle().fill(Color.uniFindMaroon.opacity(0.10)).frame(width: 92, height: 92)
                                Image(systemName: "magnifyingglass.circle.fill")
                                    .font(.system(size: 54))
                                    .foregroundStyle(Color.uniFindMaroon)
                            }
                            Text("UniFInd").font(.largeTitle.bold())
                            Text("Campus Lost & Found System")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        VStack(spacing: 14) {
                            labeledField("Email", text: $email, icon: "envelope")

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                                HStack {
                                    Group {
                                        if showPassword { TextField("Password", text: $password) }
                                        else { SecureField("Password", text: $password) }
                                    }
                                    Button { showPassword.toggle() } label: {
                                        Image(systemName: showPassword ? "eye.slash" : "eye")
                                    }
                                }
                                .padding(14)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            HStack {
                                Spacer()
                                Button("Forgot password?") { path.append(.forgotPassword) }
                                    .font(.footnote.weight(.semibold))
                            }

                            if let error = authController.errorMessage {
                                Text(error).font(.footnote).foregroundStyle(.red).frame(maxWidth: .infinity, alignment: .leading)
                            }

                            PrimaryButton(title: authController.isLoading ? "Signing In..." : "Sign In") {
                                authController.signInStudent(email: email, password: password)
                            }
                            .disabled(authController.isLoading)

                            Button("Admin Login") { showAdminLogin = true }
                                .font(.subheadline.weight(.semibold))

                            HStack(spacing: 4) {
                                Text("Don't have an account?").foregroundStyle(.secondary)
                                Button("Sign Up") { path.append(.signup) }
                                    .fontWeight(.semibold)
                            }
                            .font(.footnote)
                            .padding(.top, 8)
                        }
                        .padding(20)
                        .uniFindCard()

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, UniFIndTheme.horizontalPadding)
                }
            }
            .sheet(isPresented: $showAdminLogin) {
                NavigationStack {
                    Form {
                        Section("Security Office Account") {
                            TextField("Admin Email", text: $adminEmail)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                            SecureField("Password", text: $adminPassword)
                        }

                        Section {
                            Button(authController.isLoading ? "Signing In..." : "Sign In as Admin") {
                                authController.signInAdmin(email: adminEmail, password: adminPassword)
                            }
                            .disabled(authController.isLoading)

                            if let error = authController.errorMessage {
                                Text(error)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                        }

                        Section {
                            Text("Admin access is checked from the role stored in the Firestore users collection. Students cannot choose the admin role during sign up. Demo fallback remains available until Firebase is fully configured.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .navigationTitle("Admin Login")
                    .navigationBarTitleDisplayMode(.inline)
                    .onChange(of: authController.currentUser?.role) { role in
                        if role == .admin {
                            showAdminLogin = false
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showAdminLogin = false }
                        }
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .signup: SignUpView()
                case .forgotPassword: ForgotPasswordView()
                }
            }
        }
    }

    private func labeledField(_ title: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            HStack {
                Image(systemName: icon).foregroundStyle(.secondary)
                TextField(title, text: text).textInputAutocapitalization(.never).keyboardType(.emailAddress)
            }
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
