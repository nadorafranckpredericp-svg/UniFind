import Foundation

struct CloudinaryUploadResponse: Decodable {
    let secure_url: String
}

enum CloudinaryConfiguration {
    static let cloudName = "dcwphona2"
    static let unsignedUploadPreset = "unifind_upload"
}

enum CloudinaryUploadError: LocalizedError {
    case invalidImage
    case invalidResponse
    case uploadFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidImage: return "The selected image could not be prepared for upload."
        case .invalidResponse: return "Cloudinary returned an invalid response."
        case .uploadFailed(let message): return message
        }
    }
}

final class CloudinaryService {
    static let shared = CloudinaryService()
    private init() {}

    func uploadImage(data: Data) async throws -> String {
        guard !data.isEmpty else { throw CloudinaryUploadError.invalidImage }
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(CloudinaryConfiguration.cloudName)/image/upload")!
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.appendText("--\(boundary)\r\n")
        body.appendText("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n")
        body.appendText("\(CloudinaryConfiguration.unsignedUploadPreset)\r\n")
        body.appendText("--\(boundary)\r\n")
        body.appendText("Content-Disposition: form-data; name=\"file\"; filename=\"unifind-\(UUID().uuidString).jpg\"\r\n")
        body.appendText("Content-Type: image/jpeg\r\n\r\n")
        body.append(data)
        body.appendText("\r\n--\(boundary)--\r\n")
        request.httpBody = body

        let (responseData, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw CloudinaryUploadError.invalidResponse }
        guard (200...299).contains(http.statusCode) else {
            let message = String(data: responseData, encoding: .utf8) ?? "Cloudinary upload failed."
            throw CloudinaryUploadError.uploadFailed(message)
        }
        guard let result = try? JSONDecoder().decode(CloudinaryUploadResponse.self, from: responseData) else {
            throw CloudinaryUploadError.invalidResponse
        }
        return result.secure_url
    }
}

private extension Data {
    mutating func appendText(_ string: String) {
        if let data = string.data(using: .utf8) { append(data) }
    }
}
