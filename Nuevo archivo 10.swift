import SwiftUI

struct ExerciseDetailView: View {
    
    let exercise: Exercise
    @ObservedObject var vm: WorkoutViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // HEADER
                VStack(alignment: .leading, spacing: 5) {
                    Text(exercise.name)
                        .font(.title)
                        .bold()
                    
                    Text(exercise.tipo)
                        .foregroundColor(.gray)
                    
                    if let desc = exercise.descripcion, !desc.isEmpty {
                        Text(desc)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // 🔥 PR
                if let pr = personalRecord() {
                    Text("🏆 PR: \(Int(pr)) kg")
                        .font(.headline)
                        .foregroundColor(.yellow)
                }
                
                // 🔥 GRÁFICA SIMPLE
                VStack(alignment: .leading) {
                    Text("Progress")
                        .font(.headline)
                    
                    ProgressChart(
                        workouts: vm.workouts,
                        exerciseId: exercise.id
                    )
                    let insights = WorkoutCoach.analyze(
                        workouts: vm.workouts,
                        exerciseId: exercise.id
                    )
                    
                    CoachView(insights: insights)
                }
                
                // 🔥 HISTORIAL
                VStack(alignment: .leading, spacing: 10) {
                    Text("History")
                        .font(.headline)
                    
                    ForEach(filteredWorkouts().reversed()) { w in
                        HStack {
                            Text("\(Int(w.peso))kg x \(w.repeticiones)")
                            Spacer()
                            Text(dateString(w.fecha))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
    }
    
    // MARK: - DATA
    
    func filteredWorkouts() -> [Workout] {
        vm.workouts.filter { $0.exerciseId == exercise.id }
    }
    
    func personalRecord() -> Double? {
        filteredWorkouts()
            .map { $0.peso }
            .max()
    }
    
    func progressData() -> [(Date, Double)] {
        filteredWorkouts()
            .sorted { $0.fecha < $1.fecha }
            .map { ($0.fecha, $0.peso) }
    }
    
    func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}
