import Foundation
import Combine

final class AuthenticationController: ObservableObject {
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var connectionMessage: String?

    var isUsingFirebase: Bool { FirebaseAuthService.shared.canUseFirebase }

    func signInStudent(email: String, password: String) {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard validateCredentials(email: cleanEmail, password: password) else { return }
        guard FirebaseAuthService.shared.canUseFirebase else {
            useStudentDemoFallback(email: cleanEmail)
            return
        }

        isLoading = true
        errorMessage = nil
        Task { @MainActor in
            defer { isLoading = false }
            do {
                let session = try await FirebaseAuthService.shared.signIn(email: cleanEmail, password: password)
                let profile = try await FirebaseDataService.shared.fetchUserProfile(uid: session.uid)
                guard profile.role == .student else {
                    try? FirebaseAuthService.shared.signOut()
                    errorMessage = "This account is not registered as a student."
                    return
                }
                currentUser = user(from: profile)
                connectionMessage = "Connected to Firebase"
            } catch { errorMessage = readable(error) }
        }
    }

    func signInAdmin(email: String, password: String) {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard validateCredentials(email: cleanEmail, password: password) else { return }
        guard FirebaseAuthService.shared.canUseFirebase else {
            currentUser = SampleData.admin
            errorMessage = nil
            connectionMessage = "Demo Admin mode — Firebase is not configured yet"
            return
        }

        isLoading = true
        errorMessage = nil
        Task { @MainActor in
            defer { isLoading = false }
            do {
                let session = try await FirebaseAuthService.shared.signIn(email: cleanEmail, password: password)
                let profile = try await FirebaseDataService.shared.fetchUserProfile(uid: session.uid)
                guard profile.role == .admin else {
                    try? FirebaseAuthService.shared.signOut()
                    errorMessage = "This account does not have Security Office/Admin access."
                    return
                }
                currentUser = user(from: profile)
                connectionMessage = "Connected to Firebase"
            } catch { errorMessage = readable(error) }
        }
    }

    func signInAdmin() {
        currentUser = SampleData.admin
        errorMessage = nil
        connectionMessage = "Demo Admin mode"
    }

    func signUp(name: String, studentID: String, email: String, password: String, confirmPassword: String) -> Bool {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanID = studentID.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard validateSignUp(name: cleanName, studentID: cleanID, email: cleanEmail, password: password, confirmPassword: confirmPassword) else { return false }

        guard FirebaseAuthService.shared.canUseFirebase else {
            currentUser = User(id: UUID(), firebaseUID: nil, name: cleanName, email: cleanEmail, studentID: cleanID, role: .student)
            errorMessage = nil
            connectionMessage = "Demo account — Firebase is not configured yet"
            return true
        }

        isLoading = true
        errorMessage = nil
        Task { @MainActor in
            defer { isLoading = false }
            do {
                let session = try await FirebaseAuthService.shared.createAccount(email: cleanEmail, password: password)
                try await FirebaseDataService.shared.createStudentProfile(uid: session.uid, name: cleanName, email: session.email, studentID: cleanID)
                let profile = try await FirebaseDataService.shared.fetchUserProfile(uid: session.uid)
                currentUser = user(from: profile)
                connectionMessage = "Firebase account created"
            } catch { errorMessage = readable(error) }
        }
        return true
    }

    func validateResetEmail(_ email: String) -> Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanEmail.isEmpty else { errorMessage = "Please enter your university email."; return false }
        guard isValidUniversityEmail(cleanEmail) else { errorMessage = "Please enter a valid university email."; return false }
        errorMessage = nil
        if FirebaseAuthService.shared.canUseFirebase {
            Task { @MainActor in
                do {
                    try await FirebaseAuthService.shared.sendPasswordReset(email: cleanEmail)
                    connectionMessage = "Password reset email requested from Firebase"
                } catch { errorMessage = readable(error) }
            }
        }
        return true
    }

    func validateNewPassword(_ password: String, confirmPassword: String) -> Bool {
        guard password.count >= 6 else { errorMessage = "Password must contain at least 6 characters."; return false }
        guard password == confirmPassword else { errorMessage = "Passwords do not match."; return false }
        errorMessage = nil
        return true
    }

    func refreshFirebaseStatus() {
        connectionMessage = FirebaseAuthService.shared.canUseFirebase
            ? "Firebase Authentication + Firestore ready"
            : "Demo mode — finish Firebase setup for live data"
    }

    func clearError() { errorMessage = nil }

    func logout() {
        try? FirebaseAuthService.shared.signOut()
        currentUser = nil
        errorMessage = nil
        connectionMessage = nil
    }

    private func validateCredentials(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else { errorMessage = "Please enter your email and password."; return false }
        guard isValidUniversityEmail(email) else { errorMessage = "Please enter a valid university email."; return false }
        return true
    }

    private func validateSignUp(name: String, studentID: String, email: String, password: String, confirmPassword: String) -> Bool {
        guard !name.isEmpty, !studentID.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else { errorMessage = "Please complete all required fields."; return false }
        guard studentID.count >= 6 else { errorMessage = "Please enter a valid Student ID."; return false }
        guard isValidUniversityEmail(email) else { errorMessage = "Please enter a valid university email."; return false }
        guard password.count >= 6 else { errorMessage = "Password must contain at least 6 characters."; return false }
        guard password == confirmPassword else { errorMessage = "Passwords do not match."; return false }
        return true
    }

    private func useStudentDemoFallback(email: String) {
        var user = SampleData.student
        user.email = email
        currentUser = user
        errorMessage = nil
        connectionMessage = "Demo mode — finish Firebase setup for live login"
    }

    private func user(from profile: FirebaseUserProfile) -> User {
        User(id: UUID(), firebaseUID: profile.uid, name: profile.name, email: profile.email, studentID: profile.studentID, role: profile.role)
    }

    private func readable(_ error: Error) -> String {
        if let localized = error as? LocalizedError, let text = localized.errorDescription { return text }
        return error.localizedDescription
    }

    private func isValidUniversityEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}
