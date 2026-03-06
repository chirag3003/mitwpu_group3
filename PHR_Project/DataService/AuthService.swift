import Foundation

class AuthService {
    
    static let shared = AuthService()
    
    private init() {
        // Load saved token on init
        self.token = UserDefaults.standard.string(forKey: tokenKey)
        self.currentUser = loadUser()
    }
    
    // MARK: - Properties
    
    private let tokenKey = "auth_jwt_token"
    private let userKey = "auth_user"
    
    /// Current JWT token, nil if not logged in
    private(set) var token: String?
    
    /// Current logged-in user
    private(set) var currentUser: AuthUser?
    
    /// Whether the user is currently authenticated
    var isLoggedIn: Bool {
        return token != nil
    }
    
    // MARK: - Login
    
    /// Login (or auto-register) with phone number
    /// - Parameters:
    ///   - phoneNumber: User's phone number
    ///   - completion: Callback with success flag and optional error message
    func login(phoneNumber: String, completion: @escaping (Bool, String?) -> Void) {
        let body = AuthRequest(phoneNumber: phoneNumber)
        
        APIService.shared.request(
            endpoint: "/auth/login",
            method: .post,
            body: body
        ) { [weak self] (result: Result<AuthResponse, Error>) in
            switch result {
            case .success(let response):
                self?.saveSession(response)
                completion(true, nil)
                
            case .failure(let error):
                print("❌ AuthService: Login failed - \(error)")
                completion(false, "Login failed. Please try again.")
            }
        }
    }
    
    // MARK: - Logout
    
    func logout() {
        token = nil
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    
    // MARK: - Session Persistence
    
    private func saveSession(_ response: AuthResponse) {
        token = response.token
        currentUser = response.user
        
        UserDefaults.standard.set(response.token, forKey: tokenKey)
        
        if let userData = try? JSONEncoder().encode(response.user) {
            UserDefaults.standard.set(userData, forKey: userKey)
        }
    }
    
    private func loadUser() -> AuthUser? {
        guard let data = UserDefaults.standard.data(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(AuthUser.self, from: data)
    }
}
