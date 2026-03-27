import SwiftUI

struct DiceView: View {
    let value: Int
    let isRolling: Bool

    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .frame(width: 64, height: 64)
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)

            DiceFace(value: value)
                .frame(width: 56, height: 56)
        }
        .scaleEffect(isRolling ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isRolling)
    }
}

// MARK: - Dice Face

struct DiceFace: View {
    let value: Int

    var body: some View {
        GeometryReader { geo in
            let dotSize = geo.size.width * 0.18
            let positions = dotPositions(for: value, in: geo.size)

            ForEach(Array(positions.enumerated()), id: \.offset) { _, pos in
                Circle()
                    .fill(Color.black)
                    .frame(width: dotSize, height: dotSize)
                    .position(pos)
            }
        }
    }

    private func dotPositions(for value: Int, in size: CGSize) -> [CGPoint] {
        let w = size.width
        let h = size.height
        let p: CGFloat = 0.25 

        let tl = CGPoint(x: w * p, y: h * p)
        let tr = CGPoint(x: w * (1 - p), y: h * p)
        let ml = CGPoint(x: w * p, y: h * 0.5)
        let mc = CGPoint(x: w * 0.5, y: h * 0.5)
        let mr = CGPoint(x: w * (1 - p), y: h * 0.5)
        let bl = CGPoint(x: w * p, y: h * (1 - p))
        let br = CGPoint(x: w * (1 - p), y: h * (1 - p))

        switch value {
        case 1: return [mc]
        case 2: return [tl, br]
        case 3: return [tl, mc, br]
        case 4: return [tl, tr, bl, br]
        case 5: return [tl, tr, mc, bl, br]
        case 6: return [tl, tr, ml, mr, bl, br]
        default: return [mc]
        }
    }
}
