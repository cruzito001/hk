import SwiftUI
import MapKit

struct BusinessDetailView: View {
    let business: Business
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var languageManager = LanguageManager.shared
    @State private var selectedImageIndex = 0
    @State private var region: MKCoordinateRegion
    
    init(business: Business) {
        self.business = business
        let region = MKCoordinateRegion(
            center: business.location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        _region = State(initialValue: region)
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
            )
    }
    
    // Esta función filtra las imágenes para solo usar las que existen en los assets
    private func validImages() -> [String] {
        // Filtrar las imágenes que realmente existen
        let validImages = business.images.filter { imageName in
            UIImage(named: imageName) != nil
        }
        
        // Si no hay imágenes válidas, proporcionar fallbacks basados en la categoría
        if validImages.isEmpty {
            switch business.category {
            case .food:
                return ["comidas2"]
            case .retail:
                return ["tiendita1"]
            case .services:
                return ["tacos1"]
            case .entertainment:
                return ["iguana1"]
            case .other:
                return ["antojitos1"]
            }
        }
        
        return validImages
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Imágenes
                Group {
                    let images = validImages()
                    if images.isEmpty {
                        placeholderImage
                            .frame(height: 300)
                    } else {
                        TabView(selection: $selectedImageIndex) {
                            ForEach(images.indices, id: \.self) { index in
                                ZStack {
                                    Color.gray.opacity(0.1)
                                        .frame(height: 300)
                                        
                                    if let uiImage = UIImage(named: images[index]) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 300)
                                            .clipped()
                                            .tag(index)
                                    } else {
                                        Image(systemName: "photo")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray)
                                            .tag(index)
                                    }
                                }
                                .frame(height: 300)
                            }
                        }
                        .frame(height: 300)
                        .tabViewStyle(PageTabViewStyle())
                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Encabezado
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(business.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Label(
                                title: { Text(business.category.localizedName)
                                    .font(.subheadline)
                                },
                                icon: { Image(systemName: business.category.icon) }
                            )
                            .foregroundColor(.orange)
                        }
                        
                        // Calificación
                        HStack(spacing: 4) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(business.rating) ? "star.fill" : "star")
                                    .foregroundColor(.orange)
                            }
                            Text(String(format: "%.1f", business.rating))
                                .fontWeight(.medium)
                            Text("(\(business.reviewCount) reseñas)")
                                .foregroundColor(.gray)
                        }
                        .font(.subheadline)
                    }
                    
                    Divider()
                    
                    // Descripción
                    Text(business.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Divider()
                    
                    // Información de contacto
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Información de contacto")
                            .font(.headline)
                        
                        // Dirección
                        Label(
                            title: { Text(business.address)
                                .font(.subheadline)
                            },
                            icon: { Image(systemName: "map.fill")
                                .foregroundColor(.orange)
                            }
                        )
                        
                        // Teléfono
                        if let phone = business.phone {
                            Button(action: {
                                if let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Label(
                                    title: { Text(phone)
                                        .font(.subheadline)
                                    },
                                    icon: { Image(systemName: "phone.fill")
                                        .foregroundColor(.orange)
                                    }
                                )
                            }
                        }
                        
                        // Email
                        if let email = business.email {
                            Button(action: {
                                if let url = URL(string: "mailto:\(email)") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Label(
                                    title: { Text(email)
                                        .font(.subheadline)
                                    },
                                    icon: { Image(systemName: "envelope.fill")
                                        .foregroundColor(.orange)
                                    }
                                )
                            }
                        }
                        
                        // Sitio web
                        if let website = business.website {
                            Button(action: {
                                if let url = URL(string: "https://\(website)") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Label(
                                    title: { Text(website)
                                        .font(.subheadline)
                                    },
                                    icon: { Image(systemName: "globe")
                                        .foregroundColor(.orange)
                                    }
                                )
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Mapa
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ubicación")
                            .font(.headline)
                        
                        Map(coordinateRegion: $region, annotationItems: [business]) { business in
                            MapMarker(coordinate: business.location.coordinate, tint: .orange)
                        }
                        .frame(height: 200)
                        .cornerRadius(12)
                        
                        Button(action: {
                            openInMaps()
                        }) {
                            Label("Cómo llegar", systemImage: "map.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: business.location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = business.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

#Preview {
    NavigationView {
        BusinessDetailView(business: Business(
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
            images: ["cabrito1", "cabrito2"],
            rating: 4.8,
            reviewCount: 1250,
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
}