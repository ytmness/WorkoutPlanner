import SwiftUI
import SwiftUI

struct ConfettiView: View {
    
    var trigger: Int
    
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Circle()
                    .fill(p.color)
                    .frame(width: 8, height: 8)
                    .position(p.position)
                    .opacity(p.opacity)
            }
        }
        .onChange(of: trigger) { _ in
            generateConfetti()
        }
    }
    
    func generateConfetti() {
        particles = (0..<30).map { _ in
            ConfettiParticle()
        }
        
        for i in particles.indices {
            withAnimation(.easeOut(duration: 2)) {
                particles[i].position.y += 600
                particles[i].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint = CGPoint(x: CGFloat.random(in: 0...350), y: -20)
    var color: Color = [.red, .green, .yellow, .blue, .orange].randomElement()!
    var opacity: Double = 1
}
