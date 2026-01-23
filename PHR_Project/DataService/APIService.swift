import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}

class APIService {
    static let shared = APIService()
    private let baseURL = "https://phr.chirag.codes"
    
    private init() {}
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add Authorization here if needed later
        // request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                request.httpBody = try encoder.encode(body)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(APIError.noData)) }
                return
            }
            
            // Check for success status code (200-299)
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                // Try to parse server error message
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown Server Error"
                DispatchQueue.main.async { completion(.failure(APIError.serverError(errorMessage))) }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decodedData = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async { completion(.success(decodedData)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(APIError.decodingError)) }
            }
        }.resume()
    }
    // MARK: - Upload
    
    func upload<T: Decodable>(
        endpoint: String,
        data: Data,
        mimeType: String = "image/jpeg",
        filename: String = "file",
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = createMultipartBody(data: data, boundary: boundary, filename: filename, mimeType: mimeType)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(APIError.noData)) }
                return
            }
            
            // Check for success status code (200-299)
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown Server Error"
                DispatchQueue.main.async { completion(.failure(APIError.serverError(errorMessage))) }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decodedData = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async { completion(.success(decodedData)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(APIError.decodingError)) }
            }
        }.resume()
    }
    
    private func createMultipartBody(data: Data, boundary: String, filename: String, mimeType: String) -> Data {
        let body = NSMutableData()
        let lineBreak = "\r\n"
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\(lineBreak)")
        body.append("Content-Type: \(mimeType + lineBreak + lineBreak)")
        body.append(data)
        body.append(lineBreak)
        body.append("--\(boundary)--\(lineBreak)")
        
        return body as Data
    }
}

// Helper to append string to NSMutableData
extension NSMutableData {
    func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
