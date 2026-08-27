import SwiftUI
import SwiftUI

struct CoachView: View {
    
    let insights: [WorkoutInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Coach")
                .font(.headline)
            
            ForEach(insights) { insight in
                HStack {
                    
                    Circle()
                        .fill(color(for: insight.type))
                        .frame(width: 8, height: 8)
                    
                    Text(insight.message)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    func color(for type: InsightType) -> Color {
        switch type {
        case .good: return .green
        case .warning: return .red
        case .neutral: return .gray
        }
    }
}
