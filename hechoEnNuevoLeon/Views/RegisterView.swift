import SwiftUI
import Foundation

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var authModel: AuthenticationModel
    @StateObject private var languageManager = LanguageManager.shared
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.02)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Título
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 50))
                            .foregroundStyle(.black)
                        
                        Text(LocalizedStringKey.registerTitle.localized(languageManager.currentLanguage))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(LocalizedStringKey.registerSubtitle.localized(languageManager.currentLanguage))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Formulario de registro
                    VStack(spacing: 16) {
                        // Nombre completo
                        Text(LocalizedStringKey.fullNameLabel.localized(languageManager.currentLanguage))
                            .font(.callout)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        TextField(LocalizedStringKey.fullNamePlaceholder.localized(languageManager.currentLanguage), text: $fullName)
                            .textInputAutocapitalization(.words)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        
                        // Email
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
                        
                        // Contraseña
                        Text(LocalizedStringKey.passwordLabel.localized(languageManager.currentLanguage))
                            .font(.callout)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
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
                        
                        // Confirmar Contraseña
                        Text(LocalizedStringKey.confirmPasswordLabel.localized(languageManager.currentLanguage))
                            .font(.callout)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        HStack {
                            if isConfirmPasswordVisible {
                                TextField(LocalizedStringKey.confirmPasswordPlaceholder.localized(languageManager.currentLanguage), text: $confirmPassword)
                            } else {
                                SecureField(LocalizedStringKey.confirmPasswordPlaceholder.localized(languageManager.currentLanguage), text: $confirmPassword)
                            }
                            
                            Button(action: {
                                isConfirmPasswordVisible.toggle()
                            }) {
                                Image(systemName: isConfirmPasswordVisible ? "eye.slash.fill" : "eye.fill")
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
                    
                    // Botón de registro
                    Button(action: handleRegister) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(LocalizedStringKey.registerButton.localized(languageManager.currentLanguage))
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
                    
                    // Botón para volver al login
                    Button(action: {
                        dismiss()
                    }) {
                        Text(LocalizedStringKey.backToLogin.localized(languageManager.currentLanguage))
                            .font(.footnote)
                            .foregroundColor(.orange)
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal)
            }
        }
        .alert(LocalizedStringKey.errorTitle.localized(languageManager.currentLanguage), isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleRegister() {
        // Validaciones
        guard !fullName.isEmpty else {
            alertMessage = LocalizedStringKey.emptyName.localized(languageManager.currentLanguage)
            showingAlert = true
            return
        }
        
        guard !email.isEmpty else {
            alertMessage = LocalizedStringKey.emptyFields.localized(languageManager.currentLanguage)
            showingAlert = true
            return
        }
        
        // Validación del formato del correo
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailPred.evaluate(with: email) else {
            alertMessage = LocalizedStringKey.invalidEmail.localized(languageManager.currentLanguage)
            showingAlert = true
            return
        }
        
        // Validación de contraseñas
        guard password.count >= 6 else {
            alertMessage = LocalizedStringKey.invalidPassword.localized(languageManager.currentLanguage)
            showingAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = LocalizedStringKey.passwordsDoNotMatch.localized(languageManager.currentLanguage)
            showingAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                try await authModel.register(email: email, password: password, fullName: fullName)
                dismiss()
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            isLoading = false
        }
    }
} 