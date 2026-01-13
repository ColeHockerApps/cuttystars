import Foundation
import CoreGraphics
import Combine

@MainActor
final class AppGoalSensor: ObservableObject {

    enum State {
        case idle
        case armed
        case reached
        case failed
    }

    @Published private(set) var state: State = .idle

    var center: CGPoint
    var radius: CGFloat

    init(center: CGPoint, radius: CGFloat) {
        self.center = center
        self.radius = radius
    }

    func arm() {
        state = .armed
    }

    func reset() {
        state = .idle
    }

    func evaluate(candyPosition: CGPoint, candyRadius: CGFloat) {
        guard state == .armed else { return }

        let dx = candyPosition.x - center.x
        let dy = candyPosition.y - center.y
        let dist = sqrt(dx * dx + dy * dy)

        if dist <= radius + candyRadius {
            state = .reached
        }
    }

    func markFailedIfNeeded(outOfBounds: Bool) {
        guard state == .armed else { return }
        if outOfBounds {
            state = .failed
        }
    }
}
