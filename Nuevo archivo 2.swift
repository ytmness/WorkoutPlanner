import SwiftUI
import UserNotifications

struct RootView: View {
    
    @StateObject var session = SessionManager()
    @StateObject var exerciseVM = ExerciseViewModel()
    @StateObject var settings = SettingsViewModel()
    
    var body: some View {
        ZStack {
            
            if session.isLoggedIn {
                HomeView(session: session)
                    .environmentObject(session)
                    .environmentObject(exerciseVM)
                    .environmentObject(settings)
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .leading)
                    ))
            } else {
                LoginView(session: session)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: session.isLoggedIn)
        
        // 🔥 👇 AQUÍ VA EL onAppear (EN EL ROOT)
        .onAppear {
            requestNotificationPermission()
        }
    }
}

// 🔥 FUNCIÓN GLOBAL (MISMO ARCHIVO)
func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
        print("Permiso notificaciones: \(granted)")
    }
}
