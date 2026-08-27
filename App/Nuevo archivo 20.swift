import SwiftUI
import Foundation
import UserNotifications

struct StreakNotificationManager {
    
    static func scheduleIfNeeded(workouts: [Workout]) {
        
        let streak = WorkoutStreak.currentStreak(workouts: workouts)
        
        guard streak > 0 else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let trainedToday = workouts.contains {
            calendar.isDate($0.fecha, inSameDayAs: today)
        }
        
        // 👉 SOLO si no has entrenado hoy
        guard !trainedToday else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Don't break your streak 🔥"
        content.body = "You're on a \(streak)-day streak. Train today 💪"
        
        var date = DateComponents()
        date.hour = 20 // 8 PM
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "streakReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
