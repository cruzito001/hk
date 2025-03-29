import SwiftUI
import CoreData

enum AuthError: Error {
    case invalidCredentials
    case networkError
    case serverError
    case userAlreadyExists
    
    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "Correo electrónico o contraseña incorrectos"
        case .networkError:
            return "Error de conexión. Por favor verifica tu internet"
        case .serverError:
            return "Error del servidor. Por favor intenta más tarde"
        case .userAlreadyExists:
            return "Este correo electrónico ya está registrado"
        }
    }
}

class AuthenticationModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    private let persistenceController = PersistenceController.shared
    
    func login(email: String, password: String) async throws {
        // Simulamos un delay de red
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 segundos
        
        // Buscamos el usuario en CoreData
        if let userEntity = persistenceController.fetchUser(email: email) {
            if userEntity.password == password {
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.currentUser = User(
                        id: userEntity.id ?? UUID().uuidString,
                        email: userEntity.email ?? "",
                        name: userEntity.name ?? ""
                    )
                }
            } else {
                throw AuthError.invalidCredentials
            }
        } else {
            throw AuthError.invalidCredentials
        }
    }
    
    func register(email: String, password: String, fullName: String) async throws {
        // Simulamos un delay de red
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 segundos
        
        // Verificar si el usuario ya existe
        if persistenceController.fetchUser(email: email) != nil {
            throw AuthError.userAlreadyExists
        }
        
        // Registrar nuevo usuario en CoreData
        if let userEntity = persistenceController.createUser(email: email, password: password, name: fullName) {
            // Iniciar sesión automáticamente después del registro
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.currentUser = User(
                    id: userEntity.id ?? UUID().uuidString,
                    email: userEntity.email ?? "",
                    name: userEntity.name ?? ""
                )
            }
        } else {
            throw AuthError.serverError
        }
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
    }
}

struct User: Identifiable {
    let id: String
    let email: String
    let name: String
} 