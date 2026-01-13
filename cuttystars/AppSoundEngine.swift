import SwiftUI
import Combine
import AVFoundation

@MainActor
final class AppSoundEngine: ObservableObject {

    static let shared = AppSoundEngine()

    @Published var isEnabled: Bool = true

    private var cache: [String: AVAudioPlayer] = [:]
    private var lastPlayAt: [String: TimeInterval] = [:]
    private let minGap: TimeInterval = 0.04

    private init() {}

    func prime(_ names: [String]) {
        guard isEnabled else { return }
        for n in names { _ = player(for: n) }
    }

    func play(_ name: String, volume: Float = 1.0, rate: Float = 1.0) {
        guard isEnabled else { return }

        let now = CACurrentMediaTime()
        if let last = lastPlayAt[name], (now - last) < minGap { return }
        lastPlayAt[name] = now

        guard let p = player(for: name) else { return }
        p.currentTime = 0
        p.volume = max(0.0, min(1.0, volume))
        p.enableRate = true
        p.rate = max(0.5, min(2.0, rate))
        p.play()
    }

    func stop(_ name: String) {
        cache[name]?.stop()
    }

    func stopAll() {
        for (_, p) in cache { p.stop() }
    }

    func clearCache() {
        stopAll()
        cache.removeAll()
        lastPlayAt.removeAll()
    }

    private func player(for name: String) -> AVAudioPlayer? {
        if let p = cache[name] { return p }

        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            return nil
        }

        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.prepareToPlay()
            cache[name] = p
            return p
        } catch {
            return nil
        }
    }
}
