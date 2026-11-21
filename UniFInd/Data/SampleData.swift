import Foundation

enum SampleData {
    static let student = User(
        id: UUID(),
        firebaseUID: nil,
        name: "Francis Ronda",
        email: "student@mseuf.edu.ph",
        studentID: "2023-001234",
        role: .student
    )

    static let admin = User(
        id: UUID(),
        firebaseUID: nil,
        name: "Security Office Admin",
        email: "admin@mseuf.edu.ph",
        studentID: "ADMIN-001",
        role: .admin
    )

    static let items: [LostFoundItem] = [
        LostFoundItem(id: UUID(), name: "Black Wallet", category: "Wallets", description: "Black leather wallet with minimal design.", location: "Canteen", date: Date().addingTimeInterval(-86400), status: .availableForClaim, reportType: .found, imageName: nil, registeredBy: "Security Office", isInCustody: true, ownerName: nil),
        LostFoundItem(id: UUID(), name: "iPhone 17", category: "Electronics", description: "Dark colored iPhone reported missing near the library.", location: "Library", date: Date().addingTimeInterval(-172800), status: .lost, reportType: .lost, imageName: nil, registeredBy: "Security Office", isInCustody: false, ownerName: nil),
        LostFoundItem(id: UUID(), name: "Student ID", category: "IDs", description: "University student identification card.", location: "Gymnasium", date: Date().addingTimeInterval(-259200), status: .availableForClaim, reportType: .found, imageName: nil, registeredBy: "Security Office", isInCustody: true, ownerName: nil),
        LostFoundItem(id: UUID(), name: "Black Backpack", category: "Bags", description: "Medium black backpack with laptop compartment.", location: "Computer Laboratory", date: Date().addingTimeInterval(-345600), status: .lost, reportType: .lost, imageName: nil, registeredBy: "Security Office", isInCustody: false, ownerName: nil)
    ]
}
