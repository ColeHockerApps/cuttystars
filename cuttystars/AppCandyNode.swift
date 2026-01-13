import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class AppCandyNode: ObservableObject, Identifiable {

    let id: UUID = UUID()

    @Published var center: CGPoint
    @Published var radius: CGFloat
    @Published var velocity: CGVector
    @Published var isActive: Bool

    @Published var colorIndex: Int
    @Published var spin: CGFloat

    @Published private(set) var lastUpdatedAt: TimeInterval = 0

    init(
        center: CGPoint,
        radius: CGFloat = 14,
        velocity: CGVector = .zero,
        colorIndex: Int = 0,
        spin: CGFloat = 0,
        isActive: Bool = true
    ) {
        self.center = center
        self.radius = max(2, radius)
        self.velocity = velocity
        self.colorIndex = max(0, colorIndex)
        self.spin = spin
        self.isActive = isActive
        self.lastUpdatedAt = Date().timeIntervalSince1970
    }

    func step(dt: CGFloat, bounds: CGRect? = nil, bounce: CGFloat = 0.92) {
        guard isActive else { return }

        let d = max(0, dt)
        center = CGPoint(x: center.x + velocity.dx * d, y: center.y + velocity.dy * d)
        spin += (velocity.dx * 0.002 + velocity.dy * 0.001) * d

        if let bounds {
            var v = velocity
            var c = center
            let r = radius

            if c.x - r < bounds.minX {
                c.x = bounds.minX + r
                v.dx = abs(v.dx) * bounce
            } else if c.x + r > bounds.maxX {
                c.x = bounds.maxX - r
                v.dx = -abs(v.dx) * bounce
            }

            if c.y - r < bounds.minY {
                c.y = bounds.minY + r
                v.dy = abs(v.dy) * bounce
            } else if c.y + r > bounds.maxY {
                c.y = bounds.maxY - r
                v.dy = -abs(v.dy) * bounce
            }

            center = c
            velocity = v
        }

        lastUpdatedAt = Date().timeIntervalSince1970
    }

    func applyImpulse(_ impulse: CGVector) {
        guard isActive else { return }
        velocity = CGVector(dx: velocity.dx + impulse.dx, dy: velocity.dy + impulse.dy)
        lastUpdatedAt = Date().timeIntervalSince1970
    }

    func damp(_ factor: CGFloat) {
        guard isActive else { return }
        let f = max(0, min(1, factor))
        velocity = CGVector(dx: velocity.dx * f, dy: velocity.dy * f)
        lastUpdatedAt = Date().timeIntervalSince1970
    }

    func stop() {
        velocity = .zero
        lastUpdatedAt = Date().timeIntervalSince1970
    }

    func deactivate() {
        isActive = false
        velocity = .zero
        lastUpdatedAt = Date().timeIntervalSince1970
    }

    func distance(to other: AppCandyNode) -> CGFloat {
        let dx = other.center.x - center.x
        let dy = other.center.y - center.y
        return sqrt(dx * dx + dy * dy)
    }

    func overlaps(with other: AppCandyNode) -> Bool {
        let rr = radius + other.radius
        return distance(to: other) <= rr
    }

    func clampInside(_ rect: CGRect) {
        var c = center
        c.x = max(rect.minX + radius, min(rect.maxX - radius, c.x))
        c.y = max(rect.minY + radius, min(rect.maxY - radius, c.y))
        center = c
        lastUpdatedAt = Date().timeIntervalSince1970
    }
}
