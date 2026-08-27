import SwiftUI

class WorkoutViewModel: ObservableObject {
    
    @Published var workouts: [Workout] = []
    var userKey: String
    
    init(userEmail: String) {
        self.userKey = "workouts_\(userEmail)"
        loadWorkouts()
    }
    
    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
        saveWorkouts()
    }
    
    func saveWorkouts() {
        if let data = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }
    
    func loadWorkouts() {
        if let data = UserDefaults.standard.data(forKey: userKey),
           let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
            workouts = decoded
        }
    }
    func deleteWorkout(_ workout: Workout) {
        workouts.removeAll { $0.id == workout.id }
        saveWorkouts()
    }
    func updateWorkout(_ updated: Workout) {
        if let index = workouts.firstIndex(where: { $0.id == updated.id }) {
            workouts[index] = updated
            saveWorkouts()
        }
    }
}
