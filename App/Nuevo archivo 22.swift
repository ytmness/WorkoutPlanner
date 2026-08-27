import SwiftUI

struct HeatmapView: View {
    
    let workouts: [Workout]
    let onSelectDate: (Date) -> Void
    
    private let calendar: Calendar
    private let days: [Date]
    private let leadingEmptyDays: Int
    
    init(workouts: [Workout], onSelectDate: @escaping (Date) -> Void) {
        self.workouts = workouts
        self.onSelectDate = onSelectDate
        
        var cal = Calendar.current
        cal.firstWeekday = 2
        self.calendar = cal
        
        let today = Date()
        
        let rawDays = (0..<42).compactMap {
            cal.date(byAdding: .day, value: -$0, to: today)
        }
        
        self.days = Array(rawDays.reversed())
        
        if let first = rawDays.last {
            let weekday = cal.component(.weekday, from: first)
            self.leadingEmptyDays = (weekday + 5) % 7
        } else {
            self.leadingEmptyDays = 0
        }
    }
    
    func intensity(for date: Date) -> Int {
        let count = workouts.filter {
            calendar.isDate($0.fecha, inSameDayAs: date)
        }.count
        
        return min(count, 4)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                Text("Consistency")
                    .font(.headline)
                
                Spacer()
                
                Text("Last 6 weeks")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack {
                ForEach(["M","T","W","T","F","S","S"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 7),
                spacing: 6
            ) {
                
                ForEach(0..<leadingEmptyDays, id: \.self) { _ in
                    Color.clear.frame(height: 18)
                }
                
                ForEach(days, id: \.self) { date in
                    
                    let level = intensity(for: date)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color(for: level))
                        .frame(height: 18)
                        .overlay(
                            Text("\(calendar.component(.day, from: date))")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.7))
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                onSelectDate(date)
                            }
                        }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    func color(for level: Int) -> Color {
        switch level {
        case 0: return Color.gray.opacity(0.2)
        case 1: return Color.green.opacity(0.4)
        case 2: return Color.green.opacity(0.6)
        case 3: return Color.green.opacity(0.8)
        default: return Color.green
        }
    }
}
