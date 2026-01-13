import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class AppRopeNode: ObservableObject, Identifiable {

    let id: UUID = UUID()

    @Published var a: CGPoint
    @Published var b: CGPoint

    @Published var slack: CGFloat
    @Published var thickness: CGFloat

    @Published private(set) var length: CGFloat = 0
    @Published private(set) var tension: CGFloat = 0

    init(
        a: CGPoint,
        b: CGPoint,
        slack: CGFloat = 0.06,
        thickness: CGFloat = 6
    ) {
        self.a = a
        self.b = b
        self.slack = max(0, slack)
        self.thickness = max(1, thickness)
        recalc()
    }

    func setEndpoints(a: CGPoint, b: CGPoint) {
        self.a = a
        self.b = b
        recalc()
    }

    func recalc() {
        let d = distance(a, b)
        length = d
        let target = d * (1.0 + slack)
        tension = d <= 0.0001 ? 0 : max(0, (d - target) / max(1, target))
    }

    func contains(_ p: CGPoint, hitPadding: CGFloat = 10) -> Bool {
        let pad = max(0, hitPadding)
        let d = distancePointToSegment(p, a, b)
        return d <= (thickness * 0.5 + pad)
    }

    func cutTestSegment(from p0: CGPoint, to p1: CGPoint, thicknessPad: CGFloat = 6) -> Bool {
        let pad = max(0, thicknessPad)
        let d = segmentToSegmentDistance(p0, p1, a, b)
        return d <= (thickness * 0.5 + pad)
    }

    func cut() {
        tension = 0
    }

    private func distance(_ p0: CGPoint, _ p1: CGPoint) -> CGFloat {
        let dx = p1.x - p0.x
        let dy = p1.y - p0.y
        return sqrt(dx * dx + dy * dy)
    }

    private func clamp01(_ x: CGFloat) -> CGFloat {
        if x < 0 { return 0 }
        if x > 1 { return 1 }
        return x
    }

    private func distancePointToSegment(_ p: CGPoint, _ v: CGPoint, _ w: CGPoint) -> CGFloat {
        let l2 = (w.x - v.x) * (w.x - v.x) + (w.y - v.y) * (w.y - v.y)
        if l2 <= 0.0001 {
            return distance(p, v)
        }
        let t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2
        let tt = clamp01(t)
        let proj = CGPoint(x: v.x + tt * (w.x - v.x), y: v.y + tt * (w.y - v.y))
        return distance(p, proj)
    }

    private func segmentToSegmentDistance(_ p1: CGPoint, _ p2: CGPoint, _ q1: CGPoint, _ q2: CGPoint) -> CGFloat {
        if segmentsIntersect(p1, p2, q1, q2) { return 0 }
        let d1 = distancePointToSegment(p1, q1, q2)
        let d2 = distancePointToSegment(p2, q1, q2)
        let d3 = distancePointToSegment(q1, p1, p2)
        let d4 = distancePointToSegment(q2, p1, p2)
        return min(min(d1, d2), min(d3, d4))
    }

    private func segmentsIntersect(_ p1: CGPoint, _ p2: CGPoint, _ q1: CGPoint, _ q2: CGPoint) -> Bool {
        let o1 = orientation(p1, p2, q1)
        let o2 = orientation(p1, p2, q2)
        let o3 = orientation(q1, q2, p1)
        let o4 = orientation(q1, q2, p2)

        if o1 != o2 && o3 != o4 { return true }

        if o1 == 0 && onSegment(p1, q1, p2) { return true }
        if o2 == 0 && onSegment(p1, q2, p2) { return true }
        if o3 == 0 && onSegment(q1, p1, q2) { return true }
        if o4 == 0 && onSegment(q1, p2, q2) { return true }

        return false
    }

    private func orientation(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Int {
        let v = (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y)
        if abs(v) < 0.00001 { return 0 }
        return v > 0 ? 1 : 2
    }

    private func onSegment(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Bool {
        b.x <= max(a.x, c.x) + 0.00001 &&
        b.x + 0.00001 >= min(a.x, c.x) &&
        b.y <= max(a.y, c.y) + 0.00001 &&
        b.y + 0.00001 >= min(a.y, c.y)
    }
}
