import SwiftUI
import MapKit

struct IdentifiablePlacemark: Identifiable {
    let id = UUID()
    let placemark: MKPlacemark
}

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocation: CLLocation?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.6714, longitude: -100.3089), // Monterrey
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedPin: MKPlacemark?
    @State private var selectedAddress: String = ""
    @State private var isReverseLookup = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, 
                    annotationItems: selectedPin.map { [IdentifiablePlacemark(placemark: $0)] } ?? []) { item in
                    MapMarker(coordinate: item.placemark.coordinate, tint: .orange)
                }
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .sequenced(before: DragGesture(minimumDistance: 0))
                        .onEnded { value in
                            switch value {
                            case .second(true, let drag):
                                if let location = drag?.location {
                                    let coordinate = convertToCoordinate(location)
                                    reverseGeocode(coordinate)
                                }
                            default:
                                break
                            }
                        }
                )
                .ignoresSafeArea(edges: .bottom)
                
                // Indicador visual del centro
                if isReverseLookup {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                        .scaleEffect(1.5)
                }
                
                // Instrucciones y dirección seleccionada
                VStack {
                    Text("Mantén presionado en el mapa para seleccionar ubicación")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    if !selectedAddress.isEmpty {
                        Text(selectedAddress)
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.1))
                            )
                            .padding(.horizontal)
                    }
                    
                    // Barra de búsqueda
                    SearchBar(text: $searchText, placeholder: "Buscar ubicación")
                        .padding()
                        .onChange(of: searchText) { _ in
                            searchLocation()
                        }
                    
                    if !searchResults.isEmpty {
                        List(searchResults, id: \.self) { result in
                            Button(action: {
                                selectLocation(result)
                            }) {
                                VStack(alignment: .leading) {
                                    Text(result.name ?? "")
                                        .font(.headline)
                                    if let address = result.placemark.title {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Seleccionar ubicación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Seleccionar") {
                        if let pin = selectedPin {
                            selectedLocation = CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude)
                            dismiss()
                        }
                    }
                    .disabled(selectedPin == nil)
                }
            }
        }
    }
    
    private func convertToCoordinate(_ point: CGPoint) -> CLLocationCoordinate2D {
        let span = region.span
        let center = region.center
        
        let width = span.longitudeDelta
        let height = span.latitudeDelta
        
        let pointRatio = CGPoint(
            x: (point.x - UIScreen.main.bounds.width/2) / UIScreen.main.bounds.width,
            y: (point.y - UIScreen.main.bounds.height/2) / UIScreen.main.bounds.height
        )
        
        let coordinate = CLLocationCoordinate2D(
            latitude: center.latitude - (height * pointRatio.y),
            longitude: center.longitude + (width * pointRatio.x)
        )
        
        return coordinate
    }
    
    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        isReverseLookup = true
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            isReverseLookup = false
            if let error = error {
                print("Error en geocodificación inversa: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                let mkPlacemark = MKPlacemark(placemark: placemark)
                selectedPin = mkPlacemark
                region.center = coordinate
                
                // Formatear la dirección
                var addressComponents: [String] = []
                if let street = placemark.thoroughfare {
                    addressComponents.append(street)
                }
                if let number = placemark.subThoroughfare {
                    addressComponents.append(number)
                }
                if let locality = placemark.locality {
                    addressComponents.append(locality)
                }
                
                selectedAddress = addressComponents.joined(separator: " ")
            }
        }
    }
    
    private func searchLocation() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error searching for locations: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            searchResults = response.mapItems
        }
    }
    
    private func selectLocation(_ mapItem: MKMapItem) {
        selectedPin = mapItem.placemark
        region.center = mapItem.placemark.coordinate
        
        // Actualizar la dirección seleccionada
        var addressComponents: [String] = []
        if let street = mapItem.placemark.thoroughfare {
            addressComponents.append(street)
        }
        if let number = mapItem.placemark.subThoroughfare {
            addressComponents.append(number)
        }
        if let locality = mapItem.placemark.locality {
            addressComponents.append(locality)
        }
        
        selectedAddress = addressComponents.joined(separator: " ")
        
        searchResults = []
        searchText = ""
    }
}

#Preview {
    LocationPickerView(selectedLocation: .constant(nil))
} 