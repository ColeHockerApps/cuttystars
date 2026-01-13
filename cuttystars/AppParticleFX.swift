import Foundation
import CoreGraphics
import Combine

@MainActor
final class AppParticleFX: ObservableObject {

    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGVector
        var life: CGFloat
        var size: CGFloat
        var opacity: CGFloat
    }

    @Published private(set) var particles: [Particle] = []

    private let gravity: CGFloat = 520
    private let damping: CGFloat = 0.98

    func emitBurst(
        at point: CGPoint,
        count: Int = 18,
        speed: CGFloat = 240,
        life: CGFloat = 0.9
    ) {
        for _ in 0..<count {
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let v = CGVector(
                dx: cos(angle) * speed * CGFloat.random(in: 0.4...1.0),
                dy: sin(angle) * speed * CGFloat.random(in: 0.4...1.0)
            )

            let p = Particle(
                position: point,
                velocity: v,
                life: life,
                size: CGFloat.random(in: 4...8),
                opacity: 1.0
            )
            particles.append(p)
        }
    }

    func emitSparkTrail(
        from point: CGPoint,
        direction: CGVector,
        count: Int = 6
    ) {
        let dir = normalize(direction)

        for _ in 0..<count {
            let jitter = CGVector(
                dx: CGFloat.random(in: -40...40),
                dy: CGFloat.random(in: -40...40)
            )

            let p = Particle(
                position: point,
                velocity: CGVector(
                    dx: dir.dx * CGFloat.random(in: 120...220) + jitter.dx,
                    dy: dir.dy * CGFloat.random(in: 120...220) + jitter.dy
                ),
                life: CGFloat.random(in: 0.3...0.6),
                size: CGFloat.random(in: 2...4),
                opacity: 0.9
            )
            particles.append(p)
        }
    }

    func update(dt: CGFloat) {
        guard particles.isEmpty == false else { return }

        for i in particles.indices {
            particles[i].velocity.dy += gravity * dt
            particles[i].velocity.dx *= damping
            particles[i].velocity.dy *= damping

            particles[i].position.x += particles[i].velocity.dx * dt
            particles[i].position.y += particles[i].velocity.dy * dt

            particles[i].life -= dt
            particles[i].opacity = max(0, particles[i].life)
        }

        particles.removeAll { $0.life <= 0 }
    }

    func clear() {
        particles.removeAll()
    }

    private func normalize(_ v: CGVector) -> CGVector {
        let len = sqrt(v.dx * v.dx + v.dy * v.dy)
        guard len > 0.0001 else { return .zero }
        return CGVector(dx: v.dx / len, dy: v.dy / len)
    }
}
