import Combine
import SwiftUI

enum AppTheme {

    static let background = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.05, blue: 0.07),
            Color(red: 0.03, green: 0.03, blue: 0.05)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.72)

    static let accent = Color(red: 0.70, green: 0.80, blue: 1.00)
    static let accentSoft = Color(red: 0.85, green: 0.90, blue: 1.00)

    static let mist = Color(red: 0.92, green: 0.94, blue: 1.00)

    static let panel = Color.white.opacity(0.06)
    static let border = Color.white.opacity(0.10)
    static let shadow = Color.black.opacity(0.35)
}
