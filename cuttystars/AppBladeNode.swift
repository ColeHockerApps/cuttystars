import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class AppBladeNode: ObservableObject, Identifiable {

    let id: UUID = UUID()

    @Published var a: CGPoint
    @Published var b: CGPoint
    @Published var width: CGFloat
    @Published var isActive: Bool

    @Published private(set) var lastUpdatedAt: TimeInterval = 0

    init(a: CGPoint, b: CGPoint, width: CGFloat = 6, isActive: Bool = true) {
        self.a = a
        self.b = b
        self.width = max(1, width)
        self.isActive = isActive
        self.lastUpdatedAt = Date().timeIntervalSince1970
    }

    func setPoints(_ a: CGPoint, _ b: CGPoint) {
        self.a = a
        self.b = b
        lastUpdatedAt = Date().timeIntervalSince1970
    }

    func move(by v: CGVector) {
        a = CGPoint(x: a.x + v.dx, y: a.y + v.dy)
        b = CGPoint(x: b.x + v.dx, y: b.y + v.dy)
        lastUpdatedAt = Date().timeIntervalSince1970
    }

    func length() -> CGFloat {
        let dx = b.x - a.x
        let dy = b.y - a.y
        return sqrt(dx * dx + dy * dy)
    }

    func direction() -> CGVector {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let len = max(0.0001, sqrt(dx * dx + dy * dy))
        return CGVector(dx: dx / len, dy: dy / len)
    }

    func normal() -> CGVector {
        let d = direction()
        return CGVector(dx: -d.dy, dy: d.dx)
    }

    func distance(to p: CGPoint) -> CGFloat {
        let abx = b.x - a.x
        let aby = b.y - a.y
        let apx = p.x - a.x
        let apy = p.y - a.y

        let ab2 = abx * abx + aby * aby
        if ab2 <= 0.000001 {
            return sqrt(apx * apx + apy * apy)
        }

        var t = (apx * abx + apy * aby) / ab2
        t = max(0, min(1, t))

        let cx = a.x + abx * t
        let cy = a.y + aby * t

        let dx = p.x - cx
        let dy = p.y - cy
        return sqrt(dx * dx + dy * dy)
    }

    func intersectsCircle(center: CGPoint, radius: CGFloat) -> Bool {
        guard isActive else { return false }
        let r = max(0, radius) + width * 0.5
        return distance(to: center) <= r
    }
}
