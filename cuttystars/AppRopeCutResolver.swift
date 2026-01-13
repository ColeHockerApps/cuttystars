import Combine
import Foundation
import CoreGraphics

@MainActor
final class AppRopeCutResolver: ObservableObject {

    struct CutResult: Equatable {
        var didCut: Bool
        var firstHitIndex: Int?
        var hitPoint: CGPoint?
    }

    @Published private(set) var lastResult: CutResult = CutResult(didCut: false, firstHitIndex: nil, hitPoint: nil)

    init() {}

    func reset() {
        lastResult = CutResult(didCut: false, firstHitIndex: nil, hitPoint: nil)
    }

    func resolveCut(
        strokeFrom a: CGPoint,
        strokeTo b: CGPoint,
        segments: [AppRopeSolver.Segment]
    ) -> CutResult {
        guard segments.isEmpty == false else {
            let r = CutResult(didCut: false, firstHitIndex: nil, hitPoint: nil)
            lastResult = r
            return r
        }

        var bestIndex: Int? = nil
        var bestT: CGFloat = .greatestFiniteMagnitude
        var bestPoint: CGPoint? = nil

        for i in segments.indices {
            let s = segments[i]
            if let hit = segmentIntersection(a1: a, a2: b, b1: s.a, b2: s.b) {
                if hit.tAlongA < bestT {
                    bestT = hit.tAlongA
                    bestIndex = i
                    bestPoint = hit.point
                }
            }
        }

        let didCut = (bestIndex != nil)
        let r = CutResult(didCut: didCut, firstHitIndex: bestIndex, hitPoint: bestPoint)
        lastResult = r
        return r
    }

    func applyCutIfHit(
        strokeFrom a: CGPoint,
        strokeTo b: CGPoint,
        solver: AppRopeSolver
    ) -> Bool {
        let r = resolveCut(strokeFrom: a, strokeTo: b, segments: solver.segments)
        if r.didCut {
            solver.cut()
            return true
        }
        return false
    }

    private struct Hit {
        var point: CGPoint
        var tAlongA: CGFloat
    }

    private func segmentIntersection(a1: CGPoint, a2: CGPoint, b1: CGPoint, b2: CGPoint) -> Hit? {
        let r = CGPoint(x: a2.x - a1.x, y: a2.y - a1.y)
        let s = CGPoint(x: b2.x - b1.x, y: b2.y - b1.y)

        let denom = cross(r, s)
        if abs(denom) < 0.000001 {
            return nil
        }

        let qp = CGPoint(x: b1.x - a1.x, y: b1.y - a1.y)
        let t = cross(qp, s) / denom
        let u = cross(qp, r) / denom

        if t >= 0, t <= 1, u >= 0, u <= 1 {
            let p = CGPoint(x: a1.x + r.x * t, y: a1.y + r.y * t)
            return Hit(point: p, tAlongA: t)
        }

        return nil
    }

    private func cross(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        a.x * b.y - a.y * b.x
    }
}
