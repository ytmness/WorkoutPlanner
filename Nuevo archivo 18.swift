import SwiftUI
import Foundation

struct WorkoutStreak {
    
    static func currentStreak(workouts: [Workout]) -> Int {
        
        let calendar = Calendar.current
        
        // 🔥 Solo días únicos
        let uniqueDays = Set(
            workouts.map {
                calendar.startOfDay(for: $0.fecha)
            }
        )
        
        let sortedDays = uniqueDays.sorted(by: >)
        
        guard let firstDay = sortedDays.first else { return 0 }
        
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        // 🔥 Si hoy no entrenaste, empezamos desde ayer
        if !uniqueDays.contains(currentDate) {
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        for day in sortedDays {
            if calendar.isDate(day, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        return streak
    }
}
