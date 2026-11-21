import Foundation

#if canImport(FirebaseCore)
import FirebaseCore
#endif

enum FirebaseBootstrap {
    static var isFirebaseSDKAvailable: Bool {
        #if canImport(FirebaseCore)
        true
        #else
        false
        #endif
    }

    static var hasConfigurationFile: Bool {
        Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }

    static var isReady: Bool {
        #if canImport(FirebaseCore)
        return FirebaseApp.app() != nil
        #else
        return false
        #endif
    }

    static func configureIfPossible() {
        #if canImport(FirebaseCore)
        guard FirebaseApp.app() == nil else { return }
        guard hasConfigurationFile else {
            print("UniFInd: GoogleService-Info.plist not found. Running with demo fallback.")
            return
        }
        FirebaseApp.configure()
        #endif
    }
}
