import Combine
import Foundation
import CoreGraphics

@MainActor
final class AppRopeSolver: ObservableObject {

    struct Segment: Identifiable, Hashable {
        let id: UUID
        var a: CGPoint
        var b: CGPoint
        var length: CGFloat
    }

    @Published private(set) var segments: [Segment] = []
    @Published private(set) var isAttached: Bool = false
    @Published private(set) var didCut: Bool = false

    private var anchor: CGPoint = .zero
    private var targetId: UUID? = nil

    private var restLength: CGFloat = 0
    private var segmentCount: Int = 0

    private var stiffness: CGFloat = 0.92
    private var damping: CGFloat = 0.985

    init() {}

    func configure(stiffness: CGFloat = 0.92, damping: CGFloat = 0.985) {
        self.stiffness = max(0.05, min(0.995, stiffness))
        self.damping = max(0.80, min(0.999, damping))
    }

    func attach(
        anchor: CGPoint,
        candy: AppCandyNode,
        segments count: Int = 18,
        slack: CGFloat = 1.0
    ) {
        let n = max(2, min(64, count))
        self.anchor = anchor
        self.targetId = candy.id
        self.segmentCount = n
        self.didCut = false
        self.isAttached = true

        let dist = max(1, distance(anchor, candy.center))
        self.restLength = dist * max(0.35, min(2.0, slack))

        rebuildSegments(candyCenter: candy.center)
    }

    func detach() {
        isAttached = false
        didCut = false
        targetId = nil
        segments.removeAll()
    }

    func cut() {
        guard isAttached else { return }
        didCut = true
        detach()
    }

    func update(
        dt: CGFloat,
        candy: AppCandyNode,
        bounds: CGRect? = nil
    ) {
        guard isAttached, targetId == candy.id else { return }

        let d = max(0, dt)
        if segments.isEmpty {
            rebuildSegments(candyCenter: candy.center)
        }

        var points = makePointsFromSegments(anchor: anchor, last: candy.center)
        if points.count < 3 { return }

        let desired = max(1, restLength)
        let segLen = desired / CGFloat(max(1, points.count - 1))

        for _ in 0..<6 {
            points[0] = anchor
            points[points.count - 1] = candy.center

            for i in 0..<(points.count - 1) {
                var p0 = points[i]
                var p1 = points[i + 1]

                let dx = p1.x - p0.x
                let dy = p1.y - p0.y
                let len = sqrt(dx * dx + dy * dy)

                if len > 0.0001 {
                    let diff = (len - segLen) / len
                    let push = stiffness * 0.5 * diff
                    let ox = dx * push
                    let oy = dy * push

                    if i != 0 {
                        p0.x += ox
                        p0.y += oy
                    }

                    if i + 1 != points.count - 1 {
                        p1.x -= ox
                        p1.y -= oy
                    }

                    points[i] = p0
                    points[i + 1] = p1
                }
            }

            if let bounds {
                for i in 1..<(points.count - 1) {
                    points[i] = clamp(points[i], inside: bounds.insetBy(dx: 1, dy: 1))
                }
            }
        }

        let prevCandy = candy.center
        let newCandy = points[points.count - 1]

        let vx = (newCandy.x - prevCandy.x) / max(0.0001, d)
        let vy = (newCandy.y - prevCandy.y) / max(0.0001, d)

        candy.center = newCandy
        candy.velocity = CGVector(
            dx: (candy.velocity.dx * damping) + vx * (1 - damping),
            dy: (candy.velocity.dy * damping) + vy * (1 - damping)
        )

        writeSegments(from: points, segLen: segLen)
    }

    func setAnchor(_ p: CGPoint, candy: AppCandyNode) {
        guard isAttached, targetId == candy.id else { return }
        anchor = p
        rebuildSegments(candyCenter: candy.center)
    }

    func setSlack(_ slack: CGFloat, candy: AppCandyNode) {
        guard isAttached, targetId == candy.id else { return }
        let dist = max(1, distance(anchor, candy.center))
        restLength = dist * max(0.35, min(2.0, slack))
        rebuildSegments(candyCenter: candy.center)
    }

    private func rebuildSegments(candyCenter: CGPoint) {
        let n = max(2, segmentCount)
        let total = max(1, restLength)
        let segLen = total / CGFloat(n)

        var pts: [CGPoint] = []
        pts.reserveCapacity(n + 1)

        for i in 0...n {
            let t = CGFloat(i) / CGFloat(n)
            pts.append(lerp(anchor, candyCenter, t))
        }

        writeSegments(from: pts, segLen: segLen)
    }

    private func writeSegments(from points: [CGPoint], segLen: CGFloat) {
        var out: [Segment] = []
        out.reserveCapacity(max(0, points.count - 1))

        for i in 0..<(points.count - 1) {
            out.append(
                Segment(
                    id: UUID(),
                    a: points[i],
                    b: points[i + 1],
                    length: segLen
                )
            )
        }

        segments = out
    }

    private func makePointsFromSegments(anchor: CGPoint, last: CGPoint) -> [CGPoint] {
        if segments.isEmpty {
            return [anchor, last]
        }

        var pts: [CGPoint] = []
        pts.reserveCapacity(segments.count + 1)

        pts.append(anchor)
        for s in segments {
            pts.append(s.b)
        }
        pts[pts.count - 1] = last
        return pts
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = b.x - a.x
        let dy = b.y - a.y
        return sqrt(dx * dx + dy * dy)
    }

    private func lerp(_ a: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
        CGPoint(
            x: a.x + (b.x - a.x) * t,
            y: a.y + (b.y - a.y) * t
        )
    }

    private func clamp(_ p: CGPoint, inside r: CGRect) -> CGPoint {
        CGPoint(
            x: max(r.minX, min(r.maxX, p.x)),
            y: max(r.minY, min(r.maxY, p.y))
        )
    }
}
