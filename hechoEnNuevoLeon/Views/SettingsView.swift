import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authModel: AuthenticationModel
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        NavigationView {
            List {
                // Sección de Idioma
                Section(header: Text(LocalizedStringKey.languageSection.localized(languageManager.currentLanguage))) {
                    HStack {
                        Text(LocalizedStringKey.languageLabel.localized(languageManager.currentLanguage))
                        Spacer()
                        Button(action: {
                            languageManager.toggleLanguage()
                        }) {
                            Text(languageManager.currentLanguage == .spanish ? "Español" : "English")
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // Sección de Cuenta
                Section(header: Text(LocalizedStringKey.accountSection.localized(languageManager.currentLanguage))) {
                    if let user = authModel.currentUser {
                        HStack {
                            Text(LocalizedStringKey.emailLabel.localized(languageManager.currentLanguage))
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        authModel.logout()
                    }) {
                        HStack {
                            Text(LocalizedStringKey.logoutButton.localized(languageManager.currentLanguage))
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                    .foregroundColor(.red)
                }
                
                // Sección de Información
                Section(header: Text(LocalizedStringKey.aboutSection.localized(languageManager.currentLanguage))) {
                    HStack {
                        Text(LocalizedStringKey.versionLabel.localized(languageManager.currentLanguage))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    Link(destination: URL(string: "https://hechoennl.com/privacy")!) {
                        HStack {
                            Text(LocalizedStringKey.privacyPolicy.localized(languageManager.currentLanguage))
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Link(destination: URL(string: "https://hechoennl.com/terms")!) {
                        HStack {
                            Text(LocalizedStringKey.termsOfService.localized(languageManager.currentLanguage))
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .navigationTitle(LocalizedStringKey.settingsTitle.localized(languageManager.currentLanguage))
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationModel())
} 