import CoreData
import CoreLocation
import UIKit

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HechoEnNL")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error al cargar CoreData: \(error.localizedDescription)")
            }
        }
        
        viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Operaciones de guardado
    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                print("Cambios guardados exitosamente en CoreData")
            } catch {
                print("Error al guardar en CoreData: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Operaciones con negocios
    
    func fetchBusinesses() -> [BusinessEntity] {
        let request: NSFetchRequest<BusinessEntity> = BusinessEntity.fetchRequest()
        
        do {
            let results = try viewContext.fetch(request)
            print("Negocios recuperados de CoreData: \(results.count)")
            
            // Verificar las imágenes
            for business in results {
                if let images = business.images, !images.isEmpty {
                    print("Negocio: \(business.name ?? ""), Imágenes: \(images)")
                    
                    // Verificar si las imágenes existen en el bundle
                    for imageName in images {
                        if UIImage(named: imageName) != nil {
                            print("✅ Imagen existe: \(imageName)")
                        } else {
                            print("❌ Imagen NO existe: \(imageName)")
                        }
                    }
                } else {
                    print("⚠️ Negocio sin imágenes: \(business.name ?? "")")
                }
            }
            
            return results
        } catch {
            print("Error al cargar negocios: \(error.localizedDescription)")
            return []
        }
    }
    
    func addBusiness(_ business: Business) {
        // Determinar las imágenes a usar
        let imagesToSave: [String]
        
        // Si no hay imágenes, asignar una predeterminada según la categoría
        if business.images.isEmpty {
            switch business.category {
            case .food:
                imagesToSave = ["comidas2"]
            case .retail:
                imagesToSave = ["tiendita1"]
            case .services:
                imagesToSave = ["tacos1"]
            case .entertainment:
                imagesToSave = ["iguana1"]
            case .other:
                imagesToSave = ["antojitos1"]
            }
            print("No se proporcionaron imágenes. Asignando imagen predeterminada para categoría: \(business.category.rawValue)")
        } else {
            imagesToSave = business.images
        }
        
        print("Guardando negocio: \(business.name) con imágenes: \(imagesToSave)")
        
        let entity = BusinessEntity(context: viewContext)
        entity.id = business.id
        entity.name = business.name
        entity.businessDescription = business.description
        entity.category = business.category.rawValue
        entity.address = business.address
        entity.phone = business.phone
        entity.email = business.email
        entity.website = business.website
        entity.latitude = business.location.coordinate.latitude
        entity.longitude = business.location.coordinate.longitude
        entity.ownerId = business.ownerId
        entity.rating = business.rating
        entity.reviewCount = Int32(business.reviewCount)
        entity.createdAt = business.createdAt
        entity.updatedAt = business.updatedAt
        entity.images = imagesToSave
        
        save()
    }
    
    func deleteBusiness(_ business: Business) {
        let request: NSFetchRequest<BusinessEntity> = BusinessEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", business.id)
        
        do {
            let results = try viewContext.fetch(request)
            if let entity = results.first {
                viewContext.delete(entity)
                save()
            }
        } catch {
            print("Error al eliminar negocio: \(error.localizedDescription)")
        }
    }
    
    func deleteAllBusinesses() {
        let request: NSFetchRequest<BusinessEntity> = BusinessEntity.fetchRequest()
        
        do {
            let results = try viewContext.fetch(request)
            for entity in results {
                viewContext.delete(entity)
            }
            save()
        } catch {
            print("Error al eliminar todos los negocios: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Operaciones con usuarios
    
    func fetchUser(email: String) -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email.lowercased())
        
        do {
            let results = try viewContext.fetch(request)
            return results.first
        } catch {
            print("Error al buscar usuario: \(error.localizedDescription)")
            return nil
        }
    }
    
    func createUser(email: String, password: String, name: String) -> UserEntity? {
        let entity = UserEntity(context: viewContext)
        entity.id = UUID().uuidString
        entity.email = email.lowercased()
        entity.password = password
        entity.name = name
        entity.createdAt = Date()
        
        save()
        return entity
    }
    
    func deleteUser(_ user: UserEntity) {
        viewContext.delete(user)
        save()
    }
} 
