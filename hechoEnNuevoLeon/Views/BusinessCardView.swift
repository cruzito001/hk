import SwiftUI
import CoreLocation
import MapKit

struct BusinessCardView: View {
    let business: Business
    @StateObject private var languageManager = LanguageManager.shared
    
    private var formattedDistance: String {
        guard let distance = business.distance else { return "" }
        
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    // Obtiene el nombre de la imagen para este negocio
    private func getImageName() -> String? {
        if !business.images.isEmpty {
            for imageName in business.images {
                if UIImage(named: imageName) != nil {
                    // Usar la primera imagen válida
                    return imageName
                }
            }
        }
        
        // Si no hay imágenes válidas, usar un fallback basado en la categoría
        switch business.category {
        case .food:
            return "comidas2"
        case .retail:
            return "tiendita1"
        case .services:
            return "tacos1"
        case .entertainment:
            return "iguana1"
        case .other:
            return "antojitos1"
        }
    }
    
    var body: some View {
        NavigationLink(destination: BusinessDetailView(business: business)) {
            VStack(alignment: .leading, spacing: 16) {
                // Encabezado con categoría y distancia
                HStack(alignment: .center) {
                    Label(
                        title: { Text(business.category.localizedName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        },
                        icon: { Image(systemName: business.category.icon)
                            .foregroundColor(.orange)
                        }
                    )
                    
                    Spacer()
                    
                    if let _ = business.distance {
                        Label(
                            title: { Text(formattedDistance)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            },
                            icon: { Image(systemName: "location.fill")
                                .foregroundColor(.orange)
                            }
                        )
                    }
                }
                
                // Nombre y calificación
                VStack(alignment: .leading, spacing: 8) {
                    Text(business.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(business.rating) ? "star.fill" : "star")
                                .foregroundColor(.orange)
                        }
                        Text(String(format: "%.1f", business.rating))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        Text("(\(business.reviewCount))")
                            .foregroundColor(.gray)
                    }
                    .font(.subheadline)
                }
                
                // Descripción
                Text(business.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                // Dirección
                HStack {
                    Image(systemName: "map.fill")
                        .foregroundColor(.orange)
                    Text(business.address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                .padding(.top, 4)
                
                // Imagen del negocio
                ZStack {
                    Color.gray.opacity(0.1)
                        .frame(width: UIScreen.main.bounds.width - 64, height: 180)
                        .cornerRadius(12)
                    
                    if let imageName = getImageName(), let uiImage = UIImage(named: imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width - 64, height: 180)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 64, height: 180)
                .fixedSize(horizontal: true, vertical: true)
                .padding(.vertical, 8)
                
                // Botones de contacto
                HStack {
                    if let phone = business.phone {
                        Spacer()
                        VStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                                .font(.title3)
                            Text("Llamar")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                        Spacer()
                    }
                    
                    if let website = business.website {
                        Spacer()
                        VStack(spacing: 4) {
                            Image(systemName: "globe")
                                .font(.title3)
                            Text("Web")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                        Spacer()
                    }
                    
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "map.fill")
                            .font(.title3)
                        Text("Cómo llegar")
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                    Spacer()
                }
                .padding(.top, 8)
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width - 32)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.orange.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    BusinessCardView(business: Business(
        id: "1",
        ownerId: "owner1",
        name: "El Rey del Cabrito",
        description: "Restaurante tradicional regiomontano especializado en cabrito al pastor desde 1972.",
        category: .food,
        location: CLLocation(latitude: 25.6674, longitude: -100.3089),
        address: "José María Morelos 937, Centro, Monterrey",
        phone: "81 8343 3074",
        email: "contacto@reydelcabrito.com",
        website: "www.reydelcabrito.com",
        socialMedia: ["instagram": "@reydelcabrito", "facebook": "ReyDelCabrito"],
        images: ["cabrito1"],
        rating: 4.8,
        reviewCount: 1250,
        createdAt: Date(),
        updatedAt: Date()
    ))
    .padding()
}
