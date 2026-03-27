import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var animating = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(particle: particle, screenHeight: geo.size.height)
                }
            }
            .onAppear {
                particles = (0..<60).map { _ in
                    ConfettiParticle(
                        x: CGFloat.random(in: 0...geo.size.width),
                        color: [Color.red, .orange, .yellow, .green, .blue, .purple, .pink].randomElement()!,
                        size: CGFloat.random(in: 6...12),
                        delay: Double.random(in: 0...0.5),
                        speed: Double.random(in: 1.5...3.0),
                        rotation: Double.random(in: 0...360)
                    )
                }
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let color: Color
    let size: CGFloat
    let delay: Double
    let speed: Double
    let rotation: Double
}

struct ConfettiPiece: View {
    let particle: ConfettiParticle
    let screenHeight: CGFloat

    @State private var yOffset: CGFloat = -20
    @State private var spin: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size * 0.6)
            .rotationEffect(.degrees(spin))
            .position(x: particle.x, y: yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeIn(duration: particle.speed)
                    .delay(particle.delay)
                ) {
                    yOffset = screenHeight + 20
                    spin = particle.rotation + 720
                }
                withAnimation(
                    .easeIn(duration: particle.speed * 0.5)
                    .delay(particle.delay + particle.speed * 0.7)
                ) {
                    opacity = 0
                }
            }
    }
}
