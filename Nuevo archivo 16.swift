import SwiftUI
import Foundation

struct WorkoutInsight: Identifiable {
    let id = UUID()
    let message: String
    let type: InsightType
}

enum InsightType {
    case good
    case warning
    case neutral
}

struct WorkoutCoach {
    
    static func analyze(workouts: [Workout], exerciseId: UUID) -> [WorkoutInsight] {
        
        let filtered = workouts
            .filter { $0.exerciseId == exerciseId }
            .sorted { $0.fecha < $1.fecha }
        
        guard filtered.count >= 2 else {
            return [
                WorkoutInsight(
                    message: "Do more workouts to get insights 📊",
                    type: .neutral
                )
            ]
        }
        
        var insights: [WorkoutInsight] = []
        
        // 🔥 Volumen
        let volumes = filtered.map {
            $0.peso * Double($0.repeticiones * $0.series)
        }
        
        let last = volumes.last!
        let prev = volumes.dropLast().last!
        
        if last > prev {
            insights.append(
                WorkoutInsight(
                    message: "You're improving volume 📈",
                    type: .good
                )
            )
        } else if last < prev {
            insights.append(
                WorkoutInsight(
                    message: "Volume dropped, push harder 💀",
                    type: .warning
                )
            )
        }
        
        // 🏋️ Peso máximo
        let maxPeso = filtered.map { $0.peso }.max() ?? 0
        if let lastWorkout = filtered.last, lastWorkout.peso >= maxPeso {
            insights.append(
                WorkoutInsight(
                    message: "New PR weight 🚀",
                    type: .good
                )
            )
        }
        
        // 😴 Frecuencia
        let calendar = Calendar.current
        let recent = filtered.filter {
            calendar.dateComponents([.day], from: $0.fecha, to: Date()).day ?? 0 <= 7
        }
        
        if recent.count == 0 {
            insights.append(
                WorkoutInsight(
                    message: "You haven't trained this in a week 😴",
                    type: .warning
                )
            )
        }
        
        return insights
    }
}
