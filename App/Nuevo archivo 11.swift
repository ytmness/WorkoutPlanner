import SwiftUI 

struct SimpleLineChart: View {
    
    var data: [(Date, Double)]
    
    var body: some View {
        GeometryReader { geo in
            
            let maxVal = (data.map { $0.1 }.max() ?? 1)
            let minVal = (data.map { $0.1 }.min() ?? 0)
            let range = maxVal - minVal == 0 ? 1 : maxVal - minVal
            
            Path { path in
                for (index, point) in data.enumerated() {
                    
                    let x = geo.size.width * CGFloat(index) / CGFloat(max(data.count - 1, 1))
                    let y = geo.size.height * (1 - CGFloat((point.1 - minVal) / range))
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.green, lineWidth: 2)
        }
    }
}
