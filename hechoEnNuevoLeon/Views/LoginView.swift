import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authModel: AuthenticationModel
    @StateObject private var languageManager = LanguageManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var isPasswordVisible = false
    @State private var showRegister = false
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.02)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Botón para cambiar idioma
                    HStack {
                        Spacer()
                        Button(action: {
                            languageManager.toggleLanguage()
                        }) {
                            Text(languageManager.currentLanguage == .spanish ? "ES" : "EN")
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Logo y título
                    VStack(spacing: 8) {
                        Image(systemName: "storefront")
                            .font(.system(size: 50))
                            .foregroundStyle(.black)
                        
                        Text(LocalizedStringKey.appTitle.localized(languageManager.currentLanguage))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(LocalizedStringKey.appSubtitle.localized(languageManager.currentLanguage))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Form inicio de sesión
                    VStack(spacing: 16) {
                        Text(LocalizedStringKey.emailLabel.localized(languageManager.currentLanguage))
                            .font(.callout)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        TextField(LocalizedStringKey.emailPlaceholder.localized(languageManager.currentLanguage), text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        
                        Text(LocalizedStringKey.passwordLabel.localized(languageManager.currentLanguage))
                            .font(.callout)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        HStack {
                            if isPasswordVisible {
                                TextField(LocalizedStringKey.passwordPlaceholder.localized(languageManager.currentLanguage), text: $password)
                            } else {
                                SecureField(LocalizedStringKey.passwordPlaceholder.localized(languageManager.currentLanguage), text: $password)
                            }
                            
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                    
                    Button(action: {
                        // Lógica para el olvido de contraseña
                    }) {
                        Text(LocalizedStringKey.forgotPassword.localized(languageManager.currentLanguage))
                            .font(.footnote)
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 32)
                    
                    // Botón de inicio de sesión
                    Button(action: handleLogin) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(LocalizedStringKey.loginButton.localized(languageManager.currentLanguage))
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    HStack(spacing: 4) {
                        Text(LocalizedStringKey.noAccount.localized(languageManager.currentLanguage))
                            .foregroundColor(.gray)
                        Button(action: {
                            showRegister = true
                        }) {
                            Text(LocalizedStringKey.register.localized(languageManager.currentLanguage))
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                    .font(.footnote)
                    .padding(.top, 20)
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(authModel)
        }
        .alert(LocalizedStringKey.errorTitle.localized(languageManager.currentLanguage), isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleLogin() {
        guard !email.isEmpty && !password.isEmpty else {
            alertMessage = LocalizedStringKey.emptyFields.localized(languageManager.currentLanguage)
            showingAlert = true
            return
        }
        
        // Validación básica del formato del correo
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailPred.evaluate(with: email) else {
            alertMessage = LocalizedStringKey.invalidEmail.localized(languageManager.currentLanguage)
            showingAlert = true
            return
        }
        
        // Validación básica de la contraseña
        guard password.count >= 6 else {
            alertMessage = LocalizedStringKey.invalidPassword.localized(languageManager.currentLanguage)
            showingAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                try await authModel.login(email: email, password: password)
            } catch {
                alertMessage = "Error al iniciar sesión: \(error.localizedDescription)"
                showingAlert = true
            }
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationModel())
} 
