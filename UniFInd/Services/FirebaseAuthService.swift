import Foundation

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

enum FirebaseAuthServiceError: LocalizedError {
    case sdkUnavailable
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .sdkUnavailable: return "Firebase Auth is not added to the UniFInd target yet."
        case .notConfigured: return "Firebase is not configured. Check GoogleService-Info.plist."
        }
    }
}

struct FirebaseSession {
    let uid: String
    let email: String
}

final class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    private init() {}

    var canUseFirebase: Bool { FirebaseBootstrap.isReady }

    func signIn(email: String, password: String) async throws -> FirebaseSession {
        #if canImport(FirebaseAuth)
        guard FirebaseBootstrap.isReady else { throw FirebaseAuthServiceError.notConfigured }
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return FirebaseSession(uid: result.user.uid, email: result.user.email ?? email)
        #else
        throw FirebaseAuthServiceError.sdkUnavailable
        #endif
    }

    func createAccount(email: String, password: String) async throws -> FirebaseSession {
        #if canImport(FirebaseAuth)
        guard FirebaseBootstrap.isReady else { throw FirebaseAuthServiceError.notConfigured }
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return FirebaseSession(uid: result.user.uid, email: result.user.email ?? email)
        #else
        throw FirebaseAuthServiceError.sdkUnavailable
        #endif
    }

    func sendPasswordReset(email: String) async throws {
        #if canImport(FirebaseAuth)
        guard FirebaseBootstrap.isReady else { throw FirebaseAuthServiceError.notConfigured }
        try await Auth.auth().sendPasswordReset(withEmail: email)
        #else
        throw FirebaseAuthServiceError.sdkUnavailable
        #endif
    }

    func signOut() throws {
        #if canImport(FirebaseAuth)
        if FirebaseBootstrap.isReady { try Auth.auth().signOut() }
        #endif
    }
}
