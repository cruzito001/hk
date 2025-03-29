import Foundation
import CoreData
import CoreLocation

enum BusinessFilter {
    case nearest
    case topRated
    case newest
    
    var icon: String {
        switch self {
        case .nearest: return "location.fill"
        case .topRated: return "star.fill"
        case .newest: return "clock.fill"
        }
    }
    
    var title: String {
        switch self {
        case .nearest: return "Más cercanos"
        case .topRated: return "Mejor valorados"
        case .newest: return "Más recientes"
        }
    }
}

class BusinessService: ObservableObject {
    @Published var businesses: [Business] = []
    @Published var selectedFilter: BusinessFilter = .nearest
    private var userLocation: CLLocation?
    private let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        
        // Verificar si es la primera vez que se inicia la app
        let defaults = UserDefaults.standard
        let hasLoadedInitialData = defaults.bool(forKey: "hasLoadedInitialData")
        
        if !hasLoadedInitialData {
            // Primero borrar todos los negocios (solo la primera vez)
            persistenceController.deleteAllBusinesses()
            
            // Cargar datos de muestra
            loadSampleBusinesses()
            
            // Marcar que ya se han cargado los datos iniciales
            defaults.set(true, forKey: "hasLoadedInitialData")
        }
        
        // Cargar negocios desde CoreData
        loadBusinessesFromCoreData()
        
        // Observar notificaciones de cambios en CoreData
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextObjectsDidChange),
            name: NSManagedObjectContext.didSaveObjectsNotification,
            object: persistenceController.viewContext
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func managedObjectContextObjectsDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            self.loadBusinessesFromCoreData()
        }
    }
    
    // MARK: - Data Loading
    
    private func convertToBusiness(_ entity: BusinessEntity) -> Business {
        let location = CLLocation(
            latitude: entity.latitude,
            longitude: entity.longitude
        )
        
        var business = Business(
            id: entity.id ?? UUID().uuidString,
            ownerId: entity.ownerId ?? "",
            name: entity.name ?? "",
            description: entity.businessDescription ?? "",
            category: BusinessCategory(rawValue: entity.category ?? "other") ?? .other,
            location: location,
            address: entity.address ?? "",
            phone: entity.phone,
            email: entity.email,
            website: entity.website,
            socialMedia: [:],
            images: entity.images ?? [],
            rating: entity.rating,
            reviewCount: Int(entity.reviewCount),
            createdAt: entity.createdAt ?? Date(),
            updatedAt: entity.updatedAt ?? Date()
        )
        
        if let userLocation = self.userLocation {
            business.distance = location.distance(from: userLocation)
        }
        
        return business
    }
    
    func loadBusinessesFromCoreData() {
        let entities = persistenceController.fetchBusinesses()
        print("Cargando datos desde CoreData. Total de entidades: \(entities.count)")
        
        DispatchQueue.main.async {
            self.businesses = entities.map { self.convertToBusiness($0) }
            print("Mapeo completado. Total de negocios en memoria: \(self.businesses.count)")
            self.applyFilter()
        }
    }
    
    // MARK: - Business Operations
    
    func addBusiness(_ business: Business) {
        print("Intentando agregar negocio: \(business.name)")
        persistenceController.addBusiness(business)
        
        // Recargar los negocios desde CoreData para asegurar que se refleje el cambio
        DispatchQueue.main.async {
            self.loadBusinessesFromCoreData()
            print("Negocios recargados después de agregar. Total: \(self.businesses.count)")
        }
    }
    
    func deleteBusiness(_ business: Business) {
        persistenceController.deleteBusiness(business)
        loadBusinessesFromCoreData()
    }
    
    func updateBusiness(_ business: Business) {
        persistenceController.deleteBusiness(business)
        persistenceController.addBusiness(business)
        loadBusinessesFromCoreData()
    }
    
    // MARK: - Filtering and Sorting
    
    func filteredBusinesses(searchText: String, category: BusinessCategory?) -> [Business] {
        var filtered = businesses
        
        // Filtrar por texto de búsqueda
        if !searchText.isEmpty {
            filtered = filtered.filter { business in
                business.name.localizedCaseInsensitiveContains(searchText) ||
                business.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filtrar por categoría
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        return filtered
    }
    
    func applyFilter() {
        switch selectedFilter {
        case .nearest:
            businesses.sort { (b1, b2) -> Bool in
                guard let loc = userLocation else { return false }
                return b1.location.distance(from: loc) < b2.location.distance(from: loc)
            }
        case .topRated:
            businesses.sort { $0.rating > $1.rating }
        case .newest:
            businesses.sort { $0.createdAt > $1.createdAt }
        }
    }
    
    func updateUserLocation(_ location: CLLocation) {
        userLocation = location
        // Actualizar las distancias de todos los negocios
        businesses = businesses.map { business in
            var updatedBusiness = business
            updatedBusiness.distance = business.location.distance(from: location)
            return updatedBusiness
        }
        if selectedFilter == .nearest {
            applyFilter()
        }
    }
    
    // MARK: - Sample Data
    
    private func loadSampleBusinesses() {
        let sampleBusinesses = [
            // Restaurantes
            Business(
                id: "1",
                ownerId: "owner1",
                name: "El Rey del Cabrito",
                description: "Restaurante tradicional regiomontano especializado en cabrito al pastor desde 1972.",
                category: .food,
                location: CLLocation(latitude: 25.6674, longitude: -100.3089), // Barrio Antiguo
                address: "José María Morelos 937, Centro, Monterrey",
                phone: "81 8343 3074",
                email: "contacto@reydelcabrito.com",
                website: "www.reydelcabrito.com",
                socialMedia: ["instagram": "@reydelcabrito"],
                images: ["cabrito1", "cabrito2"],
                rating: 4.8,
                reviewCount: 1250,
                createdAt: Date(),
                updatedAt: Date()
            ),
            
            // Comercios
            Business(
                id: "2",
                ownerId: "owner2",
                name: "Mercado Barrio Antiguo",
                description: "Mercado de artesanías y productos locales en el corazón del Barrio Antiguo.",
                category: .retail,
                location: CLLocation(latitude: 25.6677, longitude: -100.3092),
                address: "Calle Mina 534, Centro, Monterrey",
                phone: "81 8342 5567",
                email: "mercado@barrioantiguomty.com",
                website: nil,
                socialMedia: ["facebook": "MercadoBarrioAntiguo"],
                images: ["mercado1","mercado2"],
                rating: 4.5,
                reviewCount: 820,
                createdAt: Date(),
                updatedAt: Date()
            ),
            
            // Servicios
            Business(
                id: "3",
                ownerId: "owner3",
                name: "Bicicletería El Pedal",
                description: "Taller de reparación y venta de bicicletas con más de 25 años de experiencia.",
                category: .services,
                location: CLLocation(latitude: 25.6715, longitude: -100.3452), // San Pedro
                address: "Av. Vasconcelos 345, San Pedro Garza García",
                phone: "81 8356 7890",
                email: "servicio@elpedal.com",
                website: "www.elpedal.com",
                socialMedia: ["instagram": "@elpedalsp"],
                images: ["bici1", "bici2"],
                rating: 4.7,
                reviewCount: 543,
                createdAt: Date(),
                updatedAt: Date()
            ),
            
            // Entretenimiento
            Business(
                id: "4",
                ownerId: "owner4",
                name: "Café Iguana",
                description: "Icónico bar y venue de música en vivo con más de 30 años de historia.",
                category: .entertainment,
                location: CLLocation(latitude: 25.6728, longitude: -100.3090), // Barrio Antiguo
                address: "Calle Morelos 1264, Centro, Monterrey",
                phone: "81 8344 7274",
                email: "eventos@cafeiguana.com",
                website: "www.cafeiguana.com",
                socialMedia: [
                    "instagram": "@cafeignuanamx",
                    "facebook": "CafeIguanaMX"
                ],
                images: ["iguana1","iguana2"],
                rating: 4.6,
                reviewCount: 2150,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Business(
                id: "5",
                ownerId: "owner5",
                name: "Fruteria Estrella",
                description: "Fruteria con productos 100% organicos",
                category: .retail,
                location: CLLocation(latitude: 25.6523517, longitude: -100.2029283), // Guadalupe
                address: "Av. Eloy Cavazos 5904, Guadalupe",
                phone: "81 2934 7689",
                email: "donraul@gmail.com",
                website: nil,
                socialMedia: ["facebook": "Fruteria La Estrella"],
                images: ["fruteria1","fruteria2"],
                rating: 4.5,
                reviewCount: 55,
                createdAt: Date(),
                updatedAt: Date()
            ),
            
            Business(
                id: "6",
                ownerId: "owner6",
                name: "Tiendita Los Abuelos",
                description: "Tienda de productos de primera calidad para el uso diario",
                category: .retail,
                location: CLLocation(latitude: 25.6784569, longitude: -100.2711643), // Guadalupe
                address: "Calle La Molienda 121, Guadalupe",
                phone: "81 6674 1243",
                email: "aguila@gmail.com",
                website: nil,
                socialMedia: ["facebook": "Tiendita de Los Abuelos"],
                images: ["tiendita2"],
                rating: 4.2,
                reviewCount: 25,
                createdAt: Date(),
                updatedAt: Date()
            ),
            
            Business(
                id: "7",
                ownerId: "owner7",
                name: "Dulceria Lolita",
                description: "Tienda para productos de fiesta y botana",
                category: .retail,
                location: CLLocation(latitude: 25.6582832, longitude: -100.1894569), // Guadalupe
                address: "Av. Pablo Livas 405B, Guadalupe",
                phone: "81 4374 9985",
                email: "dulce@gmail.com",
                website: nil,
                socialMedia: ["facebook": "Dulceria Lolita"],
                images: ["dulceria1","dulceria2"],
                rating: 4.7,
                reviewCount: 43,
                createdAt: Date(),
                updatedAt: Date()
            ),
            
            Business(
                id: "8",
                ownerId: "owner8",
                name: "Deposito 2 Amigos",
                description: "Deposito con todo tipo de bebidas y suplementos para carne asada",
                category: .retail,
                location: CLLocation(latitude: 25.664386, longitude:-100.2528991), // Guadalupe
                address: "Calle Baja California 2718, Guadalupe",
                phone: "81 4333 9315",
                email: "losamigos@gmail.com",
                website: nil,
                socialMedia: ["facebook": "Deposito 2 Amigos"],
                images: ["deposito1","deposito2"],
                rating: 4.0,
                reviewCount: 15,
                createdAt: Date(),
                updatedAt: Date()
            ),
            
            Business(
                id: "9",
                ownerId: "owner9",
                name: "Tacos Gera",
                description: "Ricos Tacos de Bisteck",
                category: .food,
                location: CLLocation(latitude: 25.676694, longitude: -100.2613924),
                address: "C. Guadalupe 227A, Guadalupe",
                phone: "81 1723 5569",
                email: "tacosGera@gmail.com",
                website: nil,
                socialMedia: ["facebook": "Fruteria Don Raúl"],
                images: ["tacos1", "tacos2"],
                rating: 4.6,
                reviewCount: 132,
                createdAt: Date(),
                updatedAt: Date()
            ),
            
            Business(
                id: "10",
                ownerId: "owner10",
                name: "Neveria Simona",
                description: "Neveria con gran cantidad y todo tipo de sabores de nieve",
                category: .food,
                location: CLLocation(latitude: 25.676694, longitude: -100.2613924),
                address: "Calle Glassglow 1140, Guadalupe",
                phone: "81 3452 4387",
                email: "heladeriaSimona@gmail.com",
                website: nil,
                socialMedia: ["facebook": "Nieves Simona"],
                images: ["neveria1", "neveria2"],
                rating: 4.0,
                reviewCount: 12,
                createdAt: Date(),
                updatedAt: Date()
            ),
            
            Business(
                id: "11",
                ownerId: "owner11",
                name: "Mariscos Las Palapas",
                description: "Restaurante de mariscos con excelente ambiente y sabor",
                category: .food,
                location: CLLocation(latitude: 25.6814921, longitude: -100.1696561),
                address: "Calle Camino las Escobas 1721, Guadalupe",
                phone: "81 1152 4457",
                email: "capi@gmail.com",
                website: nil,
                socialMedia: ["facebook": "Mariscos La Palapa"],
                images: ["mariscos1","martiscos2"],
                rating: 4.7,
                reviewCount: 100,
                createdAt: Date(),
                updatedAt: Date()
            ),
            
            Business(
                id: "12",
                ownerId: "owner12",
                name: "Antojitos Del Parque La Güera",
                description: "Ricos Antojitos mexicanos con sabor a casa",
                category: .food,
                location: CLLocation(latitude: 25.654194, longitude: -100.1913878),
                address: "Calle Fátima 7611, Guadalupe",
                phone: "81 0283 9987",
                email: "antojitos@gmail.com",
                website: nil,
                socialMedia: ["facebook": "Antojitos Doña Luz"],
                images: ["antojitos1","antojitos2"],
                rating: 4.9,
                reviewCount: 9,
                createdAt: Date(),
                updatedAt: Date()
            ),
            
            Business(
                id: "13",
                ownerId: "owner13",
                name: "Comidas De La Casa",
                description: "Ricas comidas de todo tipo de guisos con un autentico sabor a casa",
                category: .food,
                location: CLLocation(latitude: 25.6704042, longitude: -100.2871192),
                address: "Calle Emiliano Zapata 221, Guadalupe",
                phone: "81 9543 4327",
                email: "LaCasa@gmail.com",
                website: nil,
                socialMedia: ["facebook": "Güisos La Casa"],
                images: ["comidas2"],
                rating: 4.3,
                reviewCount: 73,
                createdAt: Date(),
                updatedAt: Date()
            ),

            Business(
                id: "14",
                ownerId: "owner14",
                name: "Marco Leds Y Mas",
                description: "Venta de Focos Led al Por Mayor.!!!",
                category: .services,
                location: CLLocation(latitude: 25.6597197,longitude: -100.2743101), // Guadalupe
                address: "José Peón Contreras, C. Bosques de La Pastora 2500, 67174 Guadalupe, N.L.",
                phone: "8113911517",
                email: "marcosledymass@gmail.com",
                website: "www.marcoledsymas.org",
                socialMedia: [
                    "facebook": "Marco Leds y Mas a Mayoreo SOLO Instaladores"
                ],
                images: ["Led1,Led2"],
                rating: 4.7,
                reviewCount: 172,
                createdAt: Date(),
                updatedAt: Date()
            ),

           Business(
                id: "15",
                ownerId: "owner15",
                name: "La Comedia Show Live",
                description: "Eventos a Beneficio, Privados y Especiales , Shows en Vivo, Somos el Más Grande en Comedia",
                category: .entertainment,
                location: CLLocation(latitude: 25.6840395,longitude: -100.2944127), // Barrio Antiguo
                address: "Prol Madero 3809 Ote, Fierro, 64590 Monterrey, N.L.",
                phone: "8118616565",
                email: "comediashowlive@gmail.com",
                website: "la-comedia-show-live.ueniweb.com",
                socialMedia: [
                    "instagram": "la_comedia_show_live",
                    "facebook": "La Comedia Show Live"
                ],
                images: ["Comedia1,Comedia2"],
                rating: 4.4,
                reviewCount: 504,
                createdAt: Date(),
                updatedAt: Date()
            ),

           Business(
                id: "16",
                ownerId: "owner16",
                name: "La Horda Bar Arcade",
                description: "Somos el primer Restaurant Bar Arcade Retro para adultos en el país con maquinitas totalmente originales.",
                category: .entertainment,
                location: CLLocation(latitude: 25.6678111 ,longitude: -100.3083628), // Centro Monterrey
                address: "C. Diego de Montemayor 827 sur, Barrio Antiguo, Centro, 64000 Monterrey, N.L.",
                phone: "8143128056",
                email: "lahordabararcade@gmail.com",
                website: "www.lahordabar.com",
                socialMedia: [
                    "instagram": "lahordabararcade",
                    "facebook": "La Horda Bar Arcade",
                    "tiktok": "lahordabararcade"
                ],

                images: ["Arcade1","Arcade2"],
                rating: 4.8,
                reviewCount: 7939,
                createdAt: Date(),
                updatedAt: Date()
            ),

           Business(
                id: "17",
                ownerId: "owner17",
                name: "Arma tu PC Monterrey",
                description: "Tienda de accesorios informáticos.",
                category: .services,
                location: CLLocation(latitude: 25.6550179,longitude:-100.2709201), // Monterrey
                address: "José López portillo 2136, colonia 25 de noviembre, 67174 Guadalupe, N.L.",
                phone: "5659166819",
                email: "Contacto@tunuevapcgamer.com",
                website: "www.armatupcmonterrey.com",
                socialMedia: [
                    "facebook": "Tu Nueva PC Gamer"
                ],
                images: ["pc1","pc2"],
                rating: 5.0,
                reviewCount: 45,
                createdAt: Date(),
                updatedAt: Date()
            ),

           Business(
                id: "18",
                ownerId: "owner18",
                name: "Papeleria LORE",
                description: "En Papelería Lore podrás encontrar un gran surtido de útiles escolares y más.",
                category: .services,
                location: CLLocation(latitude: 25.6632154,longitude:-100.290344), // Centro Monterrey
                address: "Aquiles Serdán 1457A, La Florida, 64800 Monterrey, N.L.",
                phone: "8137491919",
                email: "lorepape@gmail.com",
                website: "www.lorepapeleria.com",
                socialMedia: [
                    "facebook": "Papelería Lore"
                ],
                images: ["papeleria1","papeleria2"],
                rating: 4.8,
                reviewCount: 37,
                createdAt: Date(),
                updatedAt: Date()
            ),
           Business(
                id: "19",
                ownerId: "owner19",
                name: "Abbanti Comida Casera",
                description: "Comidas Caseras con Sabor de Hogar, Servicio de Comedor, a Domicilio y para Eventos.",
                category: .food,
                location: CLLocation(latitude: 25.6691125,longitude: -100.2799744), // Monterrey
                address: "Av. Federico Gómez García 1982, Buenos Aires, 64800 Monterrey, N.L.",
                phone: "8183554980",
                email: "abbanti.facturacion@gmail.com",
                website: "www.abbanti.com",
                socialMedia: [
                    "facebook": "Abbanti Comidas "
                ],
                images: ["abbanti1","abbanti2"],
                rating: 4.6,
                reviewCount: 419,
                createdAt: Date(),
                updatedAt: Date()
            ),
           Business(
                id: "20",
                ownerId: "owner20",
                name: "Vasomanía",
                description: "Tienda de venta de vasos.",
                category: .retail,
                location: CLLocation(latitude: 25.6637684 ,longitude: -100.282093), //Monterrey
                address: "Hornos Altos 207, Buenos Aires, 64800 Monterrey, N.L.",
                phone: "8132591106",
                email: "vasomania@gmail.com",
                website: "www.vasomania.com",
                socialMedia: [
                    "facebook": "Vasomanía "
                ],
                images: ["vaso1","vaso2"],
                rating: 4.4,
                reviewCount: 43,
                createdAt: Date(),
                updatedAt: Date()
            ),
           Business(
                id: "21",
                ownerId: "owner21",
                name: "FLORERIA ROMERO",
                description: "Floreria Romero expertos en Arreglos Florales e Innovadores.",
                category: .retail,
                location: CLLocation(latitude:25.6610993 ,longitude: -100.2746258 ), // Centro Monterrey
                address: "Av. José Alvarado 2008-Local 4, Jardín Español, 64820 Monterrey, N.L.",
                phone: "8116367323",
                email: "Floreriaromero61@gmail.com",
                website: "www.floreriaromero.com",
                socialMedia: [
                    "facebook": "Floreria Romero "
                ],
                images: ["floreria1","floreria2"],
                rating: 4.8,
                reviewCount: 29,
                createdAt: Date(),
                updatedAt: Date()
            ),
           Business(
                id: "22",
                ownerId: "owner22",
                name: "Naranjo’s Juicy Burgers",
                description: "Somos el primer Restaurant Bar Arcade Retro para adultos en el país con maquinitas totalmente originales.",
                category: .food,
                location: CLLocation(latitude: 25.6759795  ,longitude: -100.2569731), // Centro Guadalupe
                address: "Mier y Noriega 119, Centro de Guadalupe, 67100 Guadalupe, N.L.",
                phone: "8120502050",
                email: "naranjo@gmail.com",
                website: "www.naranjo.com",
                socialMedia: [
                    "instagram": "naranjosjuicyburgers",
                    "facebook": "Naranjos Juicy Burger"
                ],
                images: ["naranjo1","naranjo2"],
                rating: 4.7,
                reviewCount: 257,
                createdAt: Date(),
                updatedAt: Date()
            ),
           Business(
                id: "23",
                ownerId: "owner23",
                name: "EL ASTURIANO",
                description: "Tienda de ropa.",
                category: .retail,
                location: CLLocation(latitude: 25.6712874,longitude: -100.3239128), // Centro Monterrey
                address: "Santiago Tapia Ote. 151, Centro, 64000 Monterrey, N.L.",
                phone: "8183753542",
                email: "asturiano@gmail.com",
                website: "www.almaceneselasturiano.com",
                socialMedia: [
                    "facebook": "EL ASTURIANO"
                ],
                images: ["asturiano1","asturiano2"],
                rating: 4.4,
                reviewCount: 8332,
                createdAt: Date(),
                updatedAt: Date()
            ),
           Business(
                id: "24",
                ownerId: "owner24",
                name: "MALA HIERBA",
                description: "Café y restaurante para que vengas con tus amigos a realizar diferentes manualidades.",
                category: .entertainment,
                location: CLLocation(latitude: 25.6706663 ,longitude: -100.3318451), // Centro Monterrey
                address: "C. Mariano Matamoros 825, Centro, 64000 Monterrey, N.L.",
                phone: "8143128056",
                email: "malahierba.mty@gmail.com",
                website: "malahierba.mx",
                socialMedia: [
                    "instagram": "malahierba.mty",
                    "facebook": "malahierba.mty"
                ],
                images: ["malahierba1","malahierba2"],
                rating: 4.8,
                reviewCount: 1003,
                createdAt: Date(),
                updatedAt: Date()
            ),
           Business(
                id: "25",
                ownerId: "owner25",
                name: "The Burger Laboratory ",
                description: "Cientificamente las mejores hamburguesas!!.",
                category: .food,
                location: CLLocation(latitude: 25.6555803 ,longitude: -100.3132627), // Centro Monterrey
                address: "Lucila Godoy 206, Roma, 64700 Monterrey, N.L.",
                phone: "81 1771 6159",
                email: "burguerlabtec@gmail.com",
                website: "burger-lab-tec.ola.click",
                socialMedia: [
                    "facebook": "BurgerLab Tec "
                ],
                images: ["laboratory1","laboratory2"],
                rating: 4.4,
                reviewCount: 657,
                createdAt: Date(),
                updatedAt: Date()
            ),
        ]
        
        // Guardar los negocios de ejemplo en CoreData
        for business in sampleBusinesses {
            persistenceController.addBusiness(business)
        }
        
        // Recargar los datos desde CoreData
        loadBusinessesFromCoreData()
        
        // Método para forzar la recarga de todos los datos de muestra
        func reloadSampleData() {
            // Borrar todos los negocios existentes
            persistenceController.deleteAllBusinesses()
            
            // Cargar datos de muestra
            loadSampleBusinesses()
            
            // Recargar desde CoreData
            loadBusinessesFromCoreData()
            
            print("Datos de muestra recargados. Total de negocios: \(businesses.count)")
        }
    }
}
