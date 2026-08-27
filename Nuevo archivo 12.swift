import SwiftUI
import Charts

// 🔥 MÉTRICAS
enum ProgressMetric: String, CaseIterable {
    case volume = "Volume"
    case maxWeight = "Max Weight"
    case reps = "Reps"
}

struct ProgressChart: View {
    
    @EnvironmentObject var settings: SettingsViewModel
    
    @State private var selectedWorkout: Workout?
    @State private var selectedMetric: ProgressMetric = .volume
    
    let workouts: [Workout]
    let exerciseId: UUID
    
    // 🔥 FILTRO
    var filtered: [Workout] {
        workouts
            .filter { $0.exerciseId == exerciseId }
            .sorted { $0.fecha < $1.fecha }
    }
    
    // 🔥 VALOR DINÁMICO
    func value(_ w: Workout) -> Double {
        switch selectedMetric {
        case .volume:
            return w.peso * Double(w.repeticiones * w.series)
        case .maxWeight:
            return w.peso
        case .reps:
            return Double(w.repeticiones * w.series)
        }
    }
    
    // 🔥 PR
    var bestWorkout: Workout? {
        filtered.max(by: {
            value($0) < value($1)
        })
    }
    
    // 🔥 SUGERENCIA
    func suggestedWeight() -> Double? {
        guard let last = filtered.last else { return nil }
        return last.peso + 2.5
    }
    
    // 🔥 CAMBIO SEMANAL
    func weeklyChange() -> Double? {
        let calendar = Calendar.current
        let now = Date()
        
        guard
            let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now),
            let thisWeekInterval = calendar.dateInterval(of: .weekOfYear, for: now),
            let lastWeekInterval = calendar.dateInterval(of: .weekOfYear, for: lastWeek)
        else { return nil }
        
        let thisWeekValue = filtered
            .filter { thisWeekInterval.contains($0.fecha) }
            .map { value($0) }
            .reduce(0, +)
        
        let lastWeekValue = filtered
            .filter { lastWeekInterval.contains($0.fecha) }
            .map { value($0) }
            .reduce(0, +)
        
        guard lastWeekValue > 0 else { return nil }
        
        return ((thisWeekValue - lastWeekValue) / lastWeekValue) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Progress")
                .font(.headline)
            
            // 🔥 SUGERENCIA
            if let suggestion = suggestedWeight() {
                Text("Next: \(displayWeight(suggestion, unit: settings.weightUnit))")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            // 🔥 COMPARACIÓN
            if let change = weeklyChange() {
                Text(String(format: "%+.1f%% vs last week", change))
                    .font(.caption)
                    .foregroundColor(change >= 0 ? .green : .red)
            }
            
            // 🔥 SELECTOR MÉTRICA
            Picker("Metric", selection: $selectedMetric) {
                ForEach(ProgressMetric.allCases, id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(.segmented)
            
            if filtered.isEmpty {
                Text("No progress data yet")
                    .foregroundColor(.gray)
                
            } else {
                
                Chart {
                    ForEach(filtered) { workout in
                        
                        let val = value(workout)
                        
                        LineMark(
                            x: .value("Date", workout.fecha),
                            y: .value(selectedMetric.rawValue, val)
                        )
                        .foregroundStyle(.green)
                        
                        PointMark(
                            x: .value("Date", workout.fecha),
                            y: .value(selectedMetric.rawValue, val)
                        )
                        .symbolSize(selectedWorkout?.id == workout.id ? 120 : 50)
                        .foregroundStyle(
                            workout.id == bestWorkout?.id
                            ? .orange
                            : (selectedWorkout?.id == workout.id ? .yellow : .green)
                        )
                    }
                    
                    // 🔥 LÍNEA VERTICAL
                    if let selectedWorkout {
                        RuleMark(
                            x: .value("Selected", selectedWorkout.fecha)
                        )
                        .foregroundStyle(.gray.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { value in
                        AxisValueLabel(format: .dateTime.day().month())
                    }
                }
                .frame(height: 220)
                
                // 🔥 GESTURE
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { value in
                                        
                                        let origin = geo[proxy.plotAreaFrame].origin
                                        let x = value.location.x - origin.x
                                        
                                        guard let date: Date = proxy.value(atX: x) else { return }
                                        
                                        let closest = filtered.min(by: {
                                            abs($0.fecha.timeIntervalSince(date)) <
                                                abs($1.fecha.timeIntervalSince(date))
                                        })
                                        
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if selectedWorkout?.id == closest?.id {
                                                selectedWorkout = nil
                                            } else {
                                                selectedWorkout = closest
                                            }
                                        }
                                    }
                            )
                    }
                }
                
                // 🔥 TOOLTIP
                if let w = selectedWorkout {
                    
                    let val = value(w)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        
                        Text(w.fecha, format: .dateTime.day().month().year())
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(w.ejercicioNombre)
                            .font(.subheadline)
                            .bold()
                        
                        Text("\(displayWeight(w.peso, unit: settings.weightUnit)) • \(w.repeticiones)x\(w.series)")
                            .font(.subheadline)
                        
                        Text("\(selectedMetric.rawValue): \(Int(val))")
                            .font(.caption2)
                            .foregroundColor(.green)
                        
                        if w.id == bestWorkout?.id {
                            Text("🏆 Personal Record")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(10)
                    .background(Color.black.opacity(0.85))
                    .cornerRadius(10)
                    .transition(.opacity)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}
