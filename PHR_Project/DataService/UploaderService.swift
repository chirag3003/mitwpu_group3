import UIKit

class UploaderService {
    
    static let shared = UploaderService()
    
    private init() {}
    
    struct UploadResponse: Decodable {
        let url: String
        let filename: String
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // Convert Image to Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(UploaderError.imageConversionFailed))
            return
        }
        
        APIService.shared.upload(endpoint: "/uploads", data: imageData, mimeType: "image/jpeg", filename: "image.jpg") { (result: Result<UploadResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

enum UploaderError: Error {
    case imageConversionFailed
}
