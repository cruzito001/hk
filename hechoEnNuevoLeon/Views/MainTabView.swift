import SwiftUI
import CoreLocation
import CoreData

struct MainTabView: View {
    @EnvironmentObject private var authModel: AuthenticationModel
    @StateObject private var languageManager = LanguageManager.shared
    @State private var selectedTab = 0
    private let persistenceController = PersistenceController.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "map.fill" : "map")
                    Text(LocalizedStringKey.exploreTab.localized(languageManager.currentLanguage))
                }
                .tag(0)
                .environment(\.managedObjectContext, persistenceController.viewContext)
            
            MyBusinessView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "building.2.fill" : "building.2")
                    Text(LocalizedStringKey.myBusinessTab.localized(languageManager.currentLanguage))
                }
                .tag(1)
                .environment(\.managedObjectContext, persistenceController.viewContext)
            
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "gearshape.fill" : "gearshape")
                    Text(LocalizedStringKey.settingsTitle.localized(languageManager.currentLanguage))
                }
                .tag(2)
        }
        .tint(.orange)
    }
}

struct ExploreView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var businessService: BusinessService
    @State private var searchText = ""
    @State private var selectedCategory: BusinessCategory?
    @State private var showingFilterMenu = false
    @State private var userLocation = CLLocation(latitude: 25.6714, longitude: -100.3089) // Ubicación por defecto: Monterrey
    @Environment(\.managedObjectContext) private var viewContext
    
    init() {
        _businessService = StateObject(wrappedValue: BusinessService())
    }
    
    var filteredBusinesses: [Business] {
        businessService.filteredBusinesses(searchText: searchText, category: selectedCategory)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Barra de búsqueda
                SearchBar(text: $searchText, placeholder: LocalizedStringKey.searchPlaceholder.localized(languageManager.currentLanguage))
                    .padding()
                
                // Categorías horizontales con filtro
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Botón de filtro
                        Menu {
                            ForEach([BusinessFilter.nearest, .topRated, .newest], id: \.self) { filter in
                                Button(action: {
                                    businessService.selectedFilter = filter
                                    businessService.applyFilter()
                                }) {
                                    Label(filter.title, systemImage: filter.icon)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease")
                                Text(businessService.selectedFilter.title)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .foregroundColor(.orange)
                            .cornerRadius(20)
                        }
                        
                        ForEach(BusinessCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: category == selectedCategory,
                                action: {
                                    if selectedCategory == category {
                                        selectedCategory = nil
                                    } else {
                                        selectedCategory = category
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Lista de negocios
                if filteredBusinesses.isEmpty {
                    VStack {
                        Spacer()
                        Text(LocalizedStringKey.noBusinessesFound.localized(languageManager.currentLanguage))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredBusinesses) { business in
                                BusinessCardView(business: business)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle(LocalizedStringKey.nearbyBusinesses.localized(languageManager.currentLanguage))
            .onAppear {
                businessService.updateUserLocation(userLocation)
            }
        }
    }
}

struct MyBusinessView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var businessService: BusinessService
    @EnvironmentObject private var authModel: AuthenticationModel
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddBusinessSheet = false
    
    init() {
        _businessService = StateObject(wrappedValue: BusinessService())
    }
    
    private var userBusinesses: [Business] {
        let filtered = businessService.businesses.filter { $0.ownerId == authModel.currentUser?.id }
        print("Negocios filtrados para el usuario actual: \(filtered.count)")
        return filtered
    }
    
    var body: some View {
        NavigationView {
            Group {
                if userBusinesses.isEmpty {
                    // Vista para cuando no hay negocios registrados
                    VStack(spacing: 20) {
                        Image(systemName: "building.2.crop.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.orange)
                        
                        Text(LocalizedStringKey.addBusiness.localized(languageManager.currentLanguage))
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Button(action: {
                            showingAddBusinessSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text(LocalizedStringKey.addBusiness.localized(languageManager.currentLanguage))
                            }
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                        }
                    }
                    .padding()
                } else {
                    // Lista de negocios del usuario
                    List {
                        ForEach(userBusinesses) { business in
                            NavigationLink(destination: BusinessDetailView(business: business)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(business.name)
                                        .font(.headline)
                                    Text(business.category.localizedName)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: deleteBusinesses)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showingAddBusinessSheet = true
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
            .navigationTitle(LocalizedStringKey.myBusinessTab.localized(languageManager.currentLanguage))
            .sheet(isPresented: $showingAddBusinessSheet) {
                print("Sheet dismissed - Recargando datos...")
                businessService.loadBusinessesFromCoreData()
            } content: {
                AddBusinessView()
            }
            .onAppear {
                print("MyBusinessView apareció - Recargando datos...")
                businessService.loadBusinessesFromCoreData()
            }
        }
    }
    
    private func deleteBusinesses(at offsets: IndexSet) {
        for index in offsets {
            let business = userBusinesses[index]
            print("Eliminando negocio: \(business.name)")
            businessService.deleteBusiness(business)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(30)
    }
}

struct CategoryButton: View {
    let category: BusinessCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                Text(category.localizedName)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.orange : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationModel())
} 
