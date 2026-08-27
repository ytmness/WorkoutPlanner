import SwiftUI

func workoutCard(_ workout: Workout, unit: WeightUnit) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        
        HStack {
            Text(workout.tipo.uppercased())
                .font(.caption)
                .foregroundColor(.green)
            
            Spacer()
            
            Text(workout.fecha, style: .date)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        
        Text(workout.ejercicio)
            .font(.headline)
        
        Text("\(displayWeight(workout.peso, unit: unit)) • \(workout.repeticiones)x\(workout.series)")
            .foregroundColor(.gray)
    }
    .padding()
    .background(
        LinearGradient(
            colors: [Color.black.opacity(0.7), Color.gray.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
    .cornerRadius(16)
}
