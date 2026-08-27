import SwiftUI

struct HeatmapDetailView: View {
    
    let date: Date
    let workouts: [Workout]
    let unit: WeightUnit
    
    var filtered: [Workout] {
        let calendar = Calendar.current
        return workouts.filter {
            calendar.isDate($0.fecha, inSameDayAs: date)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                // 🔥 FONDO NEGRO (base de tu app)
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // HEADER
                    VStack(spacing: 6) {
                        Text(date, format: .dateTime.day().month().year())
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Day Details")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 10)
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // BODY
                    if filtered.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.title2)
                                .foregroundColor(.gray)
                            
                            Text("No workouts")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(filtered) { workout in
                                    workoutCard(workout, unit: unit)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                // 🔥 SOLO GLASS (sin gris)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .padding()
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
}
