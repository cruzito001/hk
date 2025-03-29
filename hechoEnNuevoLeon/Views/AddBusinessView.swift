import SwiftUI
import CoreLocation

struct AddBusinessView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authModel: AuthenticationModel
    @StateObject private var businessService: BusinessService
    @State private var name = ""
    @State private var description = ""
    @State private var category: BusinessCategory = .food
    @State private var address = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var website = ""
    @State private var showingImagePicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var showingLocationPicker = false
    @State private var selectedLocation: CLLocation?
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init() {
        let service = BusinessService(persistenceController: .shared)
        _businessService = StateObject(wrappedValue: service)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Información básica
                Section(header: Text("Información básica")) {
                    TextField("Nombre del negocio", text: $name)
                    
                    Picker("Categoría", selection: $category) {
                        ForEach(BusinessCategory.allCases, id: \.self) { category in
                            Text(category.localizedName)
                                .tag(category)
                        }
                    }
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .overlay(
                            Group {
                                if description.isEmpty {
                                    Text("Descripción del negocio")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 4)
                                        .padding(.top, 8)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                // Ubicación
                Section(header: Text("Ubicación")) {
                    Button(action: {
                        showingLocationPicker = true
                    }) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.orange)
                            Text(selectedLocation == nil ? "Seleccionar ubicación" : "Ubicación seleccionada")
                        }
                    }
                    
                    TextField("Dirección", text: $address)
                }
                
                // Contacto
                Section(header: Text("Información de contacto")) {
                    TextField("Teléfono", text: $phone)
                        .keyboardType(.phonePad)
                    
                    TextField("Correo electrónico", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Sitio web", text: $website)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                
                // Imágenes
                Section(header: Text("Imágenes")) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(.orange)
                            Text(selectedImages.isEmpty ? "Agregar imágenes" : "\(selectedImages.count) imágenes seleccionadas")
                        }
                    }
                    
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<selectedImages.count, id: \.self) { index in
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            Button(action: {
                                                selectedImages.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                            }
                                            .padding(4),
                                            alignment: .topTrailing
                                        )
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Agregar Negocio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveBusiness()
                    }
                    .disabled(!isValidForm)
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerView(selectedLocation: $selectedLocation)
            }
            // TODO: Implementar sheet para seleccionar imágenes
        }
    }
    
    private var isValidForm: Bool {
        // Solo requerimos:
        // - Nombre del negocio
        // - Descripción
        // - Ubicación (ya sea por picker o dirección escrita)
        // - Teléfono
        !name.isEmpty &&
        !description.isEmpty &&
        (!address.isEmpty || selectedLocation != nil) && // Permitir cualquiera de las dos opciones de ubicación
        !phone.isEmpty
    }
    
    private func saveBusiness() {
        // Si no hay ubicación seleccionada pero hay dirección, usamos geocodificación
        if selectedLocation == nil && !address.isEmpty {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    alertMessage = "No se pudo encontrar la ubicación: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                if let location = placemarks?.first?.location {
                    self.createBusiness(with: location)
                } else {
                    alertMessage = "No se pudo determinar la ubicación de la dirección proporcionada"
                    showAlert = true
                }
            }
        } else if let location = selectedLocation {
            createBusiness(with: location)
        }
    }
    
    private func createBusiness(with location: CLLocation) {
        guard let userId = authModel.currentUser?.id else {
            alertMessage = "Error de autenticación"
            showAlert = true
            return
        }
        
        // Determinar la imagen predeterminada según la categoría
        let defaultImage: String
        switch category {
        case .food:
            defaultImage = "comidas2"
        case .retail:
            defaultImage = "tiendita1" 
        case .services:
            defaultImage = "tacos1"
        case .entertainment:
            defaultImage = "iguana1"
        case .other:
            defaultImage = "antojitos1"
        }
        
        let newBusiness = Business(
            id: UUID().uuidString,
            ownerId: userId,
            name: name,
            description: description,
            category: category,
            location: location,
            address: address,
            phone: phone,
            email: email.isEmpty ? nil : email,
            website: website.isEmpty ? nil : website,
            socialMedia: [:],
            images: [defaultImage], // Usar imagen predeterminada
            rating: 0.0,
            reviewCount: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        businessService.addBusiness(newBusiness)
        dismiss()
    }
}

#Preview {
    AddBusinessView()
        .environmentObject(AuthenticationModel())
} 
