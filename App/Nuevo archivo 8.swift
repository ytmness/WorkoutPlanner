import SwiftUI
class ExerciseViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    
    private let key = "saved_exercises"
    
    init() {
        load()
    }
    
    func addExercise(_ exercise: Exercise) {
        exercises.append(exercise)
        save()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Exercise].self, from: data) {
            exercises = decoded
        }
    }
}
