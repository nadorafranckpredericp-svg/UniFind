import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

struct FirebaseUserProfile {
    let uid: String
    let name: String
    let email: String
    let studentID: String
    let role: UserRole
}

enum FirebaseDataServiceError: LocalizedError {
    case sdkUnavailable, notConfigured, profileNotFound, invalidProfile, invalidItem, invalidClaim, missingAuthenticatedUser
    var errorDescription: String? {
        switch self {
        case .sdkUnavailable: return "Firebase Firestore is not added to the UniFInd target yet."
        case .notConfigured: return "Firebase is not configured."
        case .profileNotFound: return "No UniFInd user profile was found for this account."
        case .invalidProfile: return "The UniFInd user profile is incomplete."
        case .invalidItem: return "An item record in Firestore is incomplete."
        case .invalidClaim: return "The claim information is incomplete."
        case .missingAuthenticatedUser: return "Please sign in again before submitting a claim."
        }
    }
}

final class FirebaseDataService {
    static let shared = FirebaseDataService()
    private init() {}

    var firestoreAvailable: Bool {
        #if canImport(FirebaseFirestore)
        return FirebaseBootstrap.isReady
        #else
        return false
        #endif
    }

    func createStudentProfile(uid: String, name: String, email: String, studentID: String) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isReady else { throw FirebaseDataServiceError.notConfigured }
        try await Firestore.firestore().collection("users").document(uid).setData([
            "name": name, "email": email, "studentID": studentID,
            "role": UserRole.student.rawValue, "createdAt": FieldValue.serverTimestamp()
        ])
        #else
        throw FirebaseDataServiceError.sdkUnavailable
        #endif
    }

    func fetchUserProfile(uid: String) async throws -> FirebaseUserProfile {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isReady else { throw FirebaseDataServiceError.notConfigured }
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        guard snapshot.exists, let data = snapshot.data() else { throw FirebaseDataServiceError.profileNotFound }
        guard let name = data["name"] as? String, let email = data["email"] as? String,
              let studentID = data["studentID"] as? String, let roleText = data["role"] as? String,
              let role = UserRole(rawValue: roleText) else { throw FirebaseDataServiceError.invalidProfile }
        return FirebaseUserProfile(uid: uid, name: name, email: email, studentID: studentID, role: role)
        #else
        throw FirebaseDataServiceError.sdkUnavailable
        #endif
    }

    func fetchItems() async throws -> [LostFoundItem] {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isReady else { throw FirebaseDataServiceError.notConfigured }
        let snapshot = try await Firestore.firestore().collection("items").order(by: "date", descending: true).getDocuments()
        return snapshot.documents.compactMap { document in
            let d = document.data()
            guard let name = d["name"] as? String, let category = d["category"] as? String,
                  let description = d["description"] as? String, let location = d["location"] as? String,
                  let statusText = d["status"] as? String, let status = ItemStatus(rawValue: statusText),
                  let typeText = d["reportType"] as? String, let type = ReportType(rawValue: typeText),
                  let registeredBy = d["registeredBy"] as? String else { return nil }
            let date = (d["date"] as? Timestamp)?.dateValue() ?? Date()
            return LostFoundItem(id: UUID(uuidString: document.documentID) ?? UUID(), name: name, category: category,
                description: description, location: location, date: date, status: status, reportType: type,
                imageName: d["imageURL"] as? String, registeredBy: registeredBy,
                isInCustody: d["isInCustody"] as? Bool ?? false, ownerName: d["ownerName"] as? String)
        }
        #else
        throw FirebaseDataServiceError.sdkUnavailable
        #endif
    }

    func createItem(_ item: LostFoundItem) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isReady else { throw FirebaseDataServiceError.notConfigured }
        var data: [String: Any] = [
            "name": item.name, "category": item.category, "description": item.description,
            "location": item.location, "date": Timestamp(date: item.date), "status": item.status.rawValue,
            "reportType": item.reportType.rawValue, "registeredBy": item.registeredBy,
            "isInCustody": item.isInCustody, "createdAt": FieldValue.serverTimestamp()
        ]
        if let imageURL = item.imageName { data["imageURL"] = imageURL }
        if let ownerName = item.ownerName { data["ownerName"] = ownerName }
        try await Firestore.firestore().collection("items").document(item.id.uuidString).setData(data)
        #else
        throw FirebaseDataServiceError.sdkUnavailable
        #endif
    }

    func updateItemStatus(itemID: UUID, status: ItemStatus) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isReady else { throw FirebaseDataServiceError.notConfigured }
        try await Firestore.firestore().collection("items").document(itemID.uuidString).updateData([
            "status": status.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ])
        #else
        throw FirebaseDataServiceError.sdkUnavailable
        #endif
    }

    func createClaim(_ claim: Claim) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isReady else { throw FirebaseDataServiceError.notConfigured }
        var data: [String: Any] = [
            "itemId": claim.itemID.uuidString,
            "userId": claim.userID,
            "claimantName": claim.claimantName,
            "studentID": claim.studentID,
            "itemDescription": claim.itemDescription,
            "proofDescription": claim.proofDescription,
            "status": claim.status.rawValue,
            "dateSubmitted": Timestamp(date: claim.dateSubmitted),
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let proofImageURL = claim.proofImageURL { data["proofImageURL"] = proofImageURL }
        try await Firestore.firestore().collection("claims").document(claim.id.uuidString).setData(data)
        #else
        throw FirebaseDataServiceError.sdkUnavailable
        #endif
    }

    func fetchClaims(userID: String) async throws -> [Claim] {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isReady else { throw FirebaseDataServiceError.notConfigured }
        let snapshot = try await Firestore.firestore().collection("claims")
            .whereField("userId", isEqualTo: userID)
            .getDocuments()
        return parseClaims(snapshot.documents).sorted { $0.dateSubmitted > $1.dateSubmitted }
        #else
        throw FirebaseDataServiceError.sdkUnavailable
        #endif
    }

    func fetchAllClaims() async throws -> [Claim] {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isReady else { throw FirebaseDataServiceError.notConfigured }
        let snapshot = try await Firestore.firestore().collection("claims").getDocuments()
        return parseClaims(snapshot.documents).sorted { $0.dateSubmitted > $1.dateSubmitted }
        #else
        throw FirebaseDataServiceError.sdkUnavailable
        #endif
    }

    func updateClaimStatus(claimID: UUID, status: ClaimStatus) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isReady else { throw FirebaseDataServiceError.notConfigured }
        try await Firestore.firestore().collection("claims").document(claimID.uuidString).updateData([
            "status": status.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ])
        #else
        throw FirebaseDataServiceError.sdkUnavailable
        #endif
    }

    #if canImport(FirebaseFirestore)
    private func parseClaims(_ documents: [QueryDocumentSnapshot]) -> [Claim] {
        documents.compactMap { document in
            let d = document.data()
            guard let itemIDText = d["itemId"] as? String, let itemID = UUID(uuidString: itemIDText),
                  let userID = d["userId"] as? String,
                  let claimantName = d["claimantName"] as? String,
                  let studentID = d["studentID"] as? String,
                  let proofDescription = d["proofDescription"] as? String,
                  let statusText = d["status"] as? String, let status = ClaimStatus(rawValue: statusText) else { return nil }
            return Claim(
                id: UUID(uuidString: document.documentID) ?? UUID(),
                itemID: itemID,
                userID: userID,
                claimantName: claimantName,
                studentID: studentID,
                itemDescription: d["itemDescription"] as? String ?? "",
                proofDescription: proofDescription,
                proofImageURL: d["proofImageURL"] as? String,
                status: status,
                dateSubmitted: (d["dateSubmitted"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }
    #endif
}
