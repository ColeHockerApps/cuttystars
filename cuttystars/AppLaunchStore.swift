import Foundation
import Combine

@MainActor
final class AppLaunchStore: ObservableObject {

    @Published var mainPoint: URL
    @Published var privacyPoint: URL

    private let mainKey = "app.launch.main"
    private let privacyKey = "app.launch.privacy"
    private let resumeKey = "app.launch.resume"
    private let marksKey = "app.launch.marks"

    private var didStoreResume = false

    init() {
        let defaults = UserDefaults.standard

        let defaultMain = "https://yarakselim.github.io/cuttystars/"
        let defaultPrivacy = "https://yarakselim.github.io/cuttystars-privacy"

        if let saved = defaults.string(forKey: mainKey),
           let v = URL(string: saved) {
            mainPoint = v
        } else {
            mainPoint = URL(string: defaultMain)!
        }

        if let saved = defaults.string(forKey: privacyKey),
           let v = URL(string: saved) {
            privacyPoint = v
        } else {
            privacyPoint = URL(string: defaultPrivacy)!
        }
    }

    func updateMain(_ value: String) {
        guard let v = URL(string: value) else { return }
        mainPoint = v
        UserDefaults.standard.set(value, forKey: mainKey)
    }

    func updatePrivacy(_ value: String) {
        guard let v = URL(string: value) else { return }
        privacyPoint = v
        UserDefaults.standard.set(value, forKey: privacyKey)
    }

    func storeResumeIfNeeded(_ point: URL) {
        guard didStoreResume == false else { return }
        didStoreResume = true

        let defaults = UserDefaults.standard
        if defaults.string(forKey: resumeKey) != nil { return }
        defaults.set(point.absoluteString, forKey: resumeKey)
    }

    func restoreResume() -> URL? {
        let defaults = UserDefaults.standard
        if let saved = defaults.string(forKey: resumeKey),
           let v = URL(string: saved) {
            return v
        }
        return nil
    }

    func saveMarks(_ items: [[String: Any]]) {
        UserDefaults.standard.set(items, forKey: marksKey)
    }

    func loadMarks() -> [[String: Any]]? {
        UserDefaults.standard.array(forKey: marksKey) as? [[String: Any]]
    }

    func resetAll() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: mainKey)
        defaults.removeObject(forKey: privacyKey)
        defaults.removeObject(forKey: resumeKey)
        defaults.removeObject(forKey: marksKey)
        didStoreResume = false
    }

    func normalize(_ u: URL) -> String {
        var s = u.absoluteString
        while s.count > 1, s.hasSuffix("/") { s.removeLast() }
        return s
    }
}
