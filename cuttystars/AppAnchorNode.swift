import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class AppAnchorNode: ObservableObject, Identifiable {

    let id: UUID = UUID()

    @Published var position: CGPoint
    @Published var radius: CGFloat
    @Published var isFixed: Bool

    @Published private(set) var impulse: CGVector = .zero
    @Published private(set) var lastMovedAt: TimeInterval = 0

    init(position: CGPoint, radius: CGFloat = 16, isFixed: Bool = true) {
        self.position = position
        self.radius = max(1, radius)
        self.isFixed = isFixed
        self.lastMovedAt = Date().timeIntervalSince1970
    }

    func setPosition(_ p: CGPoint, stamp: Bool = true) {
        position = p
        if stamp { lastMovedAt = Date().timeIntervalSince1970 }
    }

    func nudge(_ v: CGVector, stamp: Bool = true) {
        impulse = v
        if isFixed == false {
            position.x += v.dx
            position.y += v.dy
        }
        if stamp { lastMovedAt = Date().timeIntervalSince1970 }
    }

    func clearImpulse() {
        impulse = .zero
    }

    func contains(_ p: CGPoint, hitPadding: CGFloat = 0) -> Bool {
        let r = radius + max(0, hitPadding)
        let dx = p.x - position.x
        let dy = p.y - position.y
        return (dx * dx + dy * dy) <= (r * r)
    }

    func snapToGrid(step: CGFloat) {
        let s = max(1, step)
        let nx = (position.x / s).rounded() * s
        let ny = (position.y / s).rounded() * s
        setPosition(CGPoint(x: nx, y: ny))
    }
}
