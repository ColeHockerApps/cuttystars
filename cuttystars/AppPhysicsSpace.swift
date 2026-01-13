import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class AppPhysicsSpace: ObservableObject {

    struct Body: Identifiable {
        let id: UUID
        var position: CGPoint
        var velocity: CGVector
        var radius: CGFloat
        var isStatic: Bool
    }

    @Published private(set) var bodies: [Body] = []
    @Published private(set) var isRunning: Bool = false

    private var lastTime: TimeInterval = 0
    private let gravity: CGFloat = 980.0
    private let damping: CGFloat = 0.995

    init() {}

    func start() {
        bodies.removeAll()
        isRunning = true
        lastTime = CACurrentMediaTime()
    }

    func stop() {
        isRunning = false
    }

    func addDynamicBody(
        position: CGPoint,
        velocity: CGVector = .zero,
        radius: CGFloat
    ) -> UUID {
        let body = Body(
            id: UUID(),
            position: position,
            velocity: velocity,
            radius: radius,
            isStatic: false
        )
        bodies.append(body)
        return body.id
    }

    func addStaticBody(position: CGPoint, radius: CGFloat) -> UUID {
        let body = Body(
            id: UUID(),
            position: position,
            velocity: .zero,
            radius: radius,
            isStatic: true
        )
        bodies.append(body)
        return body.id
    }

    func update() {
        guard isRunning else { return }

        let now = CACurrentMediaTime()
        let dt = CGFloat(now - lastTime)
        lastTime = now

        guard dt > 0 else { return }

        for i in bodies.indices {
            guard bodies[i].isStatic == false else { continue }

            bodies[i].velocity.dy += gravity * dt
            bodies[i].velocity.dx *= damping
            bodies[i].velocity.dy *= damping

            bodies[i].position.x += bodies[i].velocity.dx * dt
            bodies[i].position.y += bodies[i].velocity.dy * dt
        }
    }

    func removeBody(_ id: UUID) {
        bodies.removeAll { $0.id == id }
    }

    func reset() {
        bodies.removeAll()
        isRunning = false
    }
}
