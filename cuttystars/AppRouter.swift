import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {

    enum Route: Equatable {
        case boot
        case stage
        case settings
    }

    @Published private(set) var route: Route = .boot

    init() {}

    func goBoot() {
        route = .boot
    }

    func goStage() {
        route = .stage
    }

    func goSettings() {
        route = .settings
    }
}
