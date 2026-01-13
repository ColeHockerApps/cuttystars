import SwiftUI
import Combine
import UIKit

@MainActor
final class AppHapticsManager: ObservableObject {

    static let shared = AppHapticsManager()

    @Published var isEnabled: Bool = true

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notify = UINotificationFeedbackGenerator()
    private let select = UISelectionFeedbackGenerator()

    private init() {}

    func prepare() {
        guard isEnabled else { return }
        light.prepare()
        medium.prepare()
        heavy.prepare()
        notify.prepare()
        select.prepare()
    }

    func tapLight() {
        guard isEnabled else { return }
        light.impactOccurred(intensity: 0.75)
    }

    func tapMedium() {
        guard isEnabled else { return }
        medium.impactOccurred(intensity: 0.9)
    }

    func tapHeavy() {
        guard isEnabled else { return }
        heavy.impactOccurred(intensity: 1.0)
    }

    func selectTick() {
        guard isEnabled else { return }
        select.selectionChanged()
    }

    func success() {
        guard isEnabled else { return }
        notify.notificationOccurred(.success)
    }

    func warning() {
        guard isEnabled else { return }
        notify.notificationOccurred(.warning)
    }

    func error() {
        guard isEnabled else { return }
        notify.notificationOccurred(.error)
    }
}
