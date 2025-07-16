import SwiftUI

struct SmoothTailShape: Shape {
    var phase: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let segments = 20
        let dx = rect.width / CGFloat(segments)

        path.move(to: CGPoint(x: 0, y: rect.midY))

        for i in 1...segments {
            let progress = CGFloat(i) / CGFloat(segments)
            let amplitude = (1 - progress) * rect.height * 0.4
            let angle = phase + Double(i) * 0.4
            let y = rect.midY + CGFloat(sin(angle)) * amplitude
            path.addLine(to: CGPoint(x: CGFloat(i) * dx, y: y))
        }

        return path
    }

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
}

