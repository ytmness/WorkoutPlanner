import SwiftUI
import CryptoKit

struct LoginView: View {
    
    @ObservedObject var session: SessionManager
    
    @State private var isRegister = false
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String = ""
    
    @State private var shake = false // 🔥 animación
    
    var emailIsValid: Bool {
        let normalized = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return isValidEmail(normalized)
    }
    
    var passwordIsValid: Bool {
        password.count >= 6
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 25) {
                
                Text(isRegister ? "Create Account" : "Welcome Back")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    
                    if isRegister {
                        TextField("Name", text: $name)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .onChange(of: name) { _ in errorMessage = "" }
                    }
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .onChange(of: email) { _ in errorMessage = "" }
                    if !email.isEmpty {
                        Text(emailIsValid ? "Valid email" : "Invalid email format")
                            .font(.caption)
                            .foregroundColor(emailIsValid ? .green : .red)
                    }
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .onChange(of: password) { _ in errorMessage = "" }
                    if !password.isEmpty {
                        Text(passwordIsValid ? "Valid password" : "At least 6 characters")
                            .font(.caption)
                            .foregroundColor(passwordIsValid ? .green : .red)
                    }
                }
                
                Button(action: {
                    if isRegister {
                        registerUser()
                    } else {
                        loginUser()
                    }
                }) {
                    Text(isRegister ? "REGISTER" : "LOGIN")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                
                // 🔥 ERROR MESSAGE
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .transition(.opacity)
                }
                
                Button(action: {
                    isRegister.toggle()
                    errorMessage = ""
                }) {
                    Text(isRegister ? "Already have an account? Login" : "Create account")
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
            
            // 🔥 SHAKE ANIMATION
            .offset(x: shake ? -10 : 0)
            .animation(.easeInOut(duration: 0.1), value: shake)
        }
    }
    
    // hash
    func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // REGISTER
    func registerUser() {
        errorMessage = ""
        
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            triggerShake()
            return
        }
        
        let normalizedEmail = email.lowercased()
        
        let existingUser = UserDefaults.standard.string(forKey: "pass_\(email)")
        
        guard isValidEmail(normalizedEmail) else {
            errorMessage = "Invalid email format"
            triggerShake()
            return
        }
        
        guard isValidPassword(password) else {
            errorMessage = "Password must be at least 6 characters"
            triggerShake()
            return
        }
        
        if existingUser != nil {
            errorMessage = "User already exists"
            triggerShake()
            return
        }
        
        UserDefaults.standard.set(name, forKey: "name_\(normalizedEmail)")
        let hashedPassword = hashPassword(password)
        UserDefaults.standard.set(hashedPassword, forKey: "pass_\(normalizedEmail)")
        
        session.userName = name
        session.userEmail = normalizedEmail
        session.isLoggedIn = true
    }
    
    // LOGIN
    func loginUser() {
        errorMessage = ""
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            triggerShake()
            return
        }
        
        let normalizedEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let savedPassword = UserDefaults.standard.string(forKey: "pass_\(normalizedEmail)")
        let savedName = UserDefaults.standard.string(forKey: "name_\(normalizedEmail)")
        
        guard isValidEmail(normalizedEmail) else {
            errorMessage = "Invalid email format"
            triggerShake()
            return
        }
        
        guard let savedPassword = savedPassword else {
            errorMessage = "User not found"
            triggerShake()
            return
        }
        
        let hashedInput = hashPassword(password)
        if savedPassword != hashedInput {
            errorMessage = "Incorrect password"
            triggerShake()
            return
        }
        
        session.userName = savedName ?? "User"
        session.userEmail = normalizedEmail
        session.isLoggedIn = true
    }
    
    // 🔥 SHAKE FUNCTION
    func triggerShake() {
        shake = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            shake = false
        }
    }
        func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
            let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            return predicate.evaluate(with: email)

    }
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
}
