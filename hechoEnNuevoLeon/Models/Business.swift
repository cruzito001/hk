import Foundation
import CoreLocation

enum BusinessCategory: String, CaseIterable {
    case food = "food"
    case retail = "retail"
    case services = "services"
    case entertainment = "entertainment"
    case other = "other"
    
    var localizedName: String {
        switch self {
        case .food:
            return LocalizedStringKey.food.localized(LanguageManager.shared.currentLanguage)
        case .retail:
            return LocalizedStringKey.retail.localized(LanguageManager.shared.currentLanguage)
        case .services:
            return LocalizedStringKey.services.localized(LanguageManager.shared.currentLanguage)
        case .entertainment:
            return LocalizedStringKey.entertainment.localized(LanguageManager.shared.currentLanguage)
        case .other:
            return LocalizedStringKey.other.localized(LanguageManager.shared.currentLanguage)
        }
    }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .retail: return "cart"
        case .services: return "wrench.and.screwdriver"
        case .entertainment: return "star"
        case .other: return "ellipsis"
        }
    }
}

struct Business: Identifiable {
    let id: String
    let ownerId: String
    let name: String
    let description: String
    let category: BusinessCategory
    let location: CLLocation
    let address: String
    let phone: String?
    let email: String?
    let website: String?
    let socialMedia: [String: String]
    let images: [String]
    let rating: Double
    let reviewCount: Int
    let createdAt: Date
    let updatedAt: Date
    
    var distance: Double?
    
    // Computed property para mostrar la distancia en un formato amigable
    var formattedDistance: String {
        guard let distance = distance else { return "" }
        
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
} 