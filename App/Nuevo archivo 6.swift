import SwiftUI

struct WeeklyChartView: View {
    
    var data: [String: [String: Double]]
    var onDayTap: ((String) -> Void)? = nil // 👈 callback
    
    let orderedDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let orderedTipos = ["Chest", "Back", "Legs", "Arms", "Shoulders"]
    
    @State private var animateBars = false
    
    var body: some View {
        let today = currentDay()
        
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(orderedDays, id: \.self) { day in
                
                let dayData = data[day] ?? [:]
                let total = dayData.values.reduce(0, +)
                let isToday = day == today
                
                VStack {
                    
                    VStack(spacing: 0) {
                        ForEach(orderedTipos, id: \.self) { tipo in
                            if let value = dayData[tipo], value > 0 {
                                
                                Rectangle()
                                    .fill(colorPorTipo(tipo))
                                    .frame(
                                        width: 12,
                                        height: animateBars
                                        ? barHeight(value: value, total: total)
                                        : 0
                                    )
                            }
                        }
                    }
                    .frame(height: 100, alignment: .bottom)
                    
                    Text(day)
                        .font(.caption2)
                        .foregroundColor(isToday ? .green : .gray)
                }
                .contentShape(Rectangle()) // 👈 hace toda la columna clickeable
                .onTapGesture {
                    onDayTap?(day)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateBars = true
            }
        }
    }
    
    func barHeight(value: Double, total: Double) -> CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(value / total) * 100
    }
    
    func currentDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: Date())
    }
    
    func colorPorTipo(_ tipo: String) -> Color {
        switch tipo {
        case "Chest": return .red
        case "Back": return .blue
        case "Legs": return .orange
        case "Arms": return .purple
        case "Shoulders": return .green
        default: return .gray
        }
    }
}
