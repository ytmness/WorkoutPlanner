import SwiftUI

struct StreakView: View {
    
    let streak: Int
    
    var body: some View {
        HStack {
            
            VStack(alignment: .leading) {
                Text("Current Streak")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("\(streak) days 🔥")
                    .font(.title2)
                    .bold()
            }
            
            Spacer()
            
        }
        .padding()
        .background(
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    var emoji: String {
        if streak >= 7 { return "🔥🔥🔥" }
        if streak >= 3 { return "🔥🔥" }
        if streak >= 1 { return "🔥" }
        return "😴"
    }
    
    var gradient: [Color] {
        if streak >= 7 { return [Color.orange, Color.red] }
        if streak >= 3 { return [Color.yellow, Color.orange] }
        if streak >= 1 { return [Color.green, Color.yellow] }
        return [Color.gray, Color.black]
    }
}
