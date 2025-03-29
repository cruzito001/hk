import Foundation

enum Language {
    case english
    case spanish
    
    var identifier: String {
        switch self {
        case .english: return "en"
        case .spanish: return "es"
        }
    }
}

enum LocalizedStringKey: String {
    // Login View
    case appTitle = "app_title"
    case appSubtitle = "app_subtitle"
    case emailLabel = "email_label"
    case emailPlaceholder = "email_placeholder"
    case passwordLabel = "password_label"
    case passwordPlaceholder = "password_placeholder"
    case loginButton = "login_button"
    case forgotPassword = "forgot_password"
    case noAccount = "no_account"
    case register = "register"
    
    // Register View
    case registerTitle = "register_title"
    case registerSubtitle = "register_subtitle"
    case fullNameLabel = "full_name_label"
    case fullNamePlaceholder = "full_name_placeholder"
    case confirmPasswordLabel = "confirm_password_label"
    case confirmPasswordPlaceholder = "confirm_password_placeholder"
    case registerButton = "register_button"
    case backToLogin = "back_to_login"
    
    // Main View
    case exploreTab = "explore_tab"
    case myBusinessTab = "my_business_tab"
    case searchPlaceholder = "search_placeholder"
    case nearbyBusinesses = "nearby_businesses"
    case addBusiness = "add_business"
    case noBusinessesFound = "no_businesses_found"
    case distance = "distance"
    case categories = "categories"
    case logout = "logout"
    
    // Settings View
    case settingsTitle = "settings_title"
    case languageSection = "language_section"
    case languageLabel = "language_label"
    case accountSection = "account_section"
    case logoutButton = "logout_button"
    case aboutSection = "about_section"
    case versionLabel = "version_label"
    case privacyPolicy = "privacy_policy"
    case termsOfService = "terms_of_service"
    
    // Business Categories
    case food = "category_food"
    case retail = "category_retail"
    case services = "category_services"
    case entertainment = "category_entertainment"
    case other = "category_other"
    
    // Validation Messages
    case errorTitle = "error_title"
    case emptyFields = "empty_fields"
    case invalidEmail = "invalid_email"
    case invalidPassword = "invalid_password"
    case emptyName = "empty_name"
    case passwordsDoNotMatch = "passwords_do_not_match"
    
    private var localized: [Language: String] {
        switch self {
        // Login View translations
        case .appTitle:
            return [.english: "Made in NL", .spanish: "Hecho en NL"]
        case .appSubtitle:
            return [.english: "Discover local", .spanish: "Descubre lo local"]
        case .emailLabel:
            return [.english: "Email", .spanish: "Correo electrónico"]
        case .emailPlaceholder:
            return [.english: "Enter your email", .spanish: "Ingresa tu correo"]
        case .passwordLabel:
            return [.english: "Password", .spanish: "Contraseña"]
        case .passwordPlaceholder:
            return [.english: "Enter your password", .spanish: "Ingresa tu contraseña"]
        case .loginButton:
            return [.english: "LOGIN", .spanish: "INICIAR SESIÓN"]
        case .forgotPassword:
            return [.english: "Forgot password?", .spanish: "¿Olvidaste tu contraseña?"]
        case .noAccount:
            return [.english: "Don't have an account?", .spanish: "¿No tienes cuenta?"]
        case .register:
            return [.english: "Register!", .spanish: "¡Regístrate!"]
            
        // Register View translations
        case .registerTitle:
            return [.english: "Create Account", .spanish: "Crear cuenta"]
        case .registerSubtitle:
            return [.english: "Join our community", .spanish: "Únete a nuestra comunidad"]
        case .fullNameLabel:
            return [.english: "Full Name", .spanish: "Nombre completo"]
        case .fullNamePlaceholder:
            return [.english: "Enter your full name", .spanish: "Ingresa tu nombre completo"]
        case .confirmPasswordLabel:
            return [.english: "Confirm Password", .spanish: "Confirmar contraseña"]
        case .confirmPasswordPlaceholder:
            return [.english: "Enter your password again", .spanish: "Ingresa tu contraseña nuevamente"]
        case .registerButton:
            return [.english: "REGISTER", .spanish: "REGISTRARSE"]
        case .backToLogin:
            return [.english: "Already have an account? Login", .spanish: "¿Ya tienes cuenta? Inicia sesión"]
            
        // Main View translations
        case .exploreTab:
            return [.english: "Explore", .spanish: "Explorar"]
        case .myBusinessTab:
            return [.english: "My Business", .spanish: "Mi Negocio"]
        case .searchPlaceholder:
            return [.english: "Search local businesses...", .spanish: "Buscar negocios locales..."]
        case .nearbyBusinesses:
            return [.english: "Nearby Businesses", .spanish: "Negocios Cercanos"]
        case .addBusiness:
            return [.english: "Add Your Business", .spanish: "Agregar tu Negocio"]
        case .noBusinessesFound:
            return [.english: "No businesses found nearby", .spanish: "No se encontraron negocios cercanos"]
        case .distance:
            return [.english: "Distance", .spanish: "Distancia"]
        case .categories:
            return [.english: "Categories", .spanish: "Categorías"]
        case .logout:
            return [.english: "Logout", .spanish: "Cerrar Sesión"]
            
        // Settings View translations
        case .settingsTitle:
            return [.english: "Settings", .spanish: "Configuración"]
        case .languageSection:
            return [.english: "Language", .spanish: "Idioma"]
        case .languageLabel:
            return [.english: "App Language", .spanish: "Idioma de la App"]
        case .accountSection:
            return [.english: "Account", .spanish: "Cuenta"]
        case .logoutButton:
            return [.english: "Logout", .spanish: "Cerrar Sesión"]
        case .aboutSection:
            return [.english: "About", .spanish: "Acerca de"]
        case .versionLabel:
            return [.english: "Version", .spanish: "Versión"]
        case .privacyPolicy:
            return [.english: "Privacy Policy", .spanish: "Política de Privacidad"]
        case .termsOfService:
            return [.english: "Terms of Service", .spanish: "Términos de Servicio"]
            
        // Categories translations
        case .food:
            return [.english: "Food & Drinks", .spanish: "Alimentos y Bebidas"]
        case .retail:
            return [.english: "Retail", .spanish: "Comercio"]
        case .services:
            return [.english: "Services", .spanish: "Servicios"]
        case .entertainment:
            return [.english: "Entertainment", .spanish: "Entretenimiento"]
        case .other:
            return [.english: "Other", .spanish: "Otros"]
            
        // Error and validation translations
        case .errorTitle:
            return [.english: "Error", .spanish: "Error"]
        case .emptyFields:
            return [.english: "Please fill in all fields", .spanish: "Por favor llena todos los campos"]
        case .invalidEmail:
            return [.english: "Please enter a valid email", .spanish: "Por favor ingresa un correo electrónico válido"]
        case .invalidPassword:
            return [.english: "Password must be at least 6 characters", .spanish: "La contraseña debe tener al menos 6 caracteres"]
        case .emptyName:
            return [.english: "Please enter your name", .spanish: "Por favor ingresa tu nombre"]
        case .passwordsDoNotMatch:
            return [.english: "Passwords do not match", .spanish: "Las contraseñas no coinciden"]
        }
    }
    
    func localized(_ language: Language) -> String {
        return self.localized[language] ?? ""
    }
}

// Clase para manejar el idioma actual
class LanguageManager: ObservableObject {
    @Published var currentLanguage: Language = .spanish // Idioma por defecto
    
    static let shared = LanguageManager()
    
    func toggleLanguage() {
        currentLanguage = currentLanguage == .spanish ? .english : .spanish
    }
} 