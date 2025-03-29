//
//  hechoEnNuevoLeonApp.swift
//  hechoEnNuevoLeon
//
//  Created by Alan Joel Cruz Ortega on 28/03/25.
//

import SwiftUI

@main
struct hechoEnNuevoLeonApp: App {
    @StateObject private var authModel = AuthenticationModel()
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            if authModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authModel)
                    .environment(\.managedObjectContext, persistenceController.viewContext)
            } else {
                LoginView()
                    .environmentObject(authModel)
            }
        }
    }
}
