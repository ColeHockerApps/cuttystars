import SwiftUI
import Combine

struct AppLoadingScreen: View {

    @State private var appear: Bool = false
    @State private var spin: Double = 0
    @State private var pulse: Bool = false
    @State private var drift: CGFloat = -0.18
    @State private var twinkle: Double = 0

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            ambient

            VStack(spacing: 16) {
                Spacer()

                AppStarLoader(spin: spin, pulse: pulse, twinkle: twinkle)
                    .frame(width: 210, height: 210)

                Text("Loading")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary.opacity(0.9))
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.35), value: appear)

                Spacer()
            }
            .padding(.bottom, 10)
        }
        .onAppear {
            appear = true
            pulse = true

            withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                spin = 360
            }
            withAnimation(.easeInOut(duration: 1.05).repeatForever(autoreverses: true)) {
                twinkle = 1.0
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                drift = 0.22
            }
        }
    }

    private var ambient: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Color.black.opacity(0.22)

                glowBlob(
                    size: min(w, h) * 0.92,
                    x: w * 0.20,
                    y: h * 0.22,
                    a: AppTheme.accent.opacity(0.30),
                    b: AppTheme.accentSoft.opacity(0.12),
                    drift: drift
                )

                glowBlob(
                    size: min(w, h) * 0.78,
                    x: w * 0.82,
                    y: h * 0.42,
                    a: AppTheme.mist.opacity(0.20),
                    b: AppTheme.accent.opacity(0.10),
                    drift: -drift * 0.85
                )

                glowBlob(
                    size: min(w, h) * 0.64,
                    x: w * 0.48,
                    y: h * 0.78,
                    a: AppTheme.mist.opacity(0.16),
                    b: AppTheme.accentSoft.opacity(0.10),
                    drift: drift * 0.65
                )

                vignette
            }
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }

    private func glowBlob(
        size: CGFloat,
        x: CGFloat,
        y: CGFloat,
        a: Color,
        b: Color,
        drift: CGFloat
    ) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [a, b, Color.clear],
                    center: .center,
                    startRadius: 8,
                    endRadius: size * 0.56
                )
            )
            .frame(width: size, height: size)
            .position(x: x, y: y)
            .offset(x: drift * 140, y: drift * 110)
            .scaleEffect(pulse ? 1.03 : 0.97)
            .blur(radius: 22)
            .blendMode(.screen)
            .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: pulse)
    }

    private var vignette: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.28),
                        Color.black.opacity(0.64)
                    ],
                    center: .center,
                    startRadius: 170,
                    endRadius: 900
                )
            )
            .blendMode(.multiply)
            .allowsHitTesting(false)
    }
}

private struct AppStarLoader: View {

    let spin: Double
    let pulse: Bool
    let twinkle: Double

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let c = CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.5)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.accentSoft.opacity(0.30),
                                AppTheme.mist.opacity(0.12),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: side * 0.52
                        )
                    )
                    .frame(width: side * 0.98, height: side * 0.98)
                    .position(c)
                    .scaleEffect(pulse ? 1.03 : 0.98)
                    .blur(radius: 12)
                    .blendMode(.screen)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulse)

                ForEach(0..<14, id: \.self) { i in
                    AppOrbitStar(i: i, spin: spin, twinkle: twinkle)
                        .position(c)
                }

                AppCoreStar(t: twinkle)
                    .frame(width: side * 0.26, height: side * 0.26)
                    .position(c)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct AppOrbitStar: View {
    let i: Int
    let spin: Double
    let twinkle: Double

    var body: some View {
        let count = 14.0
        let base = Double(i) / count * 360.0
        let rad = (base + spin) * Double.pi / 180.0

        let ring = 62.0 + Double(i % 4) * 16.0
        let wobble = sin((spin * 0.9 + Double(i) * 24.0) * Double.pi / 180.0) * (2.0 + Double(i % 3) * 1.4)

        let x = cos(rad) * (ring + wobble)
        let y = sin(rad) * (ring + wobble)

        let size = 7.0 + Double(i % 3) * 2.6
        let local = abs(sin((twinkle * 1.7 + Double(i) * 0.32) * Double.pi))
        let alpha = 0.35 + local * 0.55

        return Image(systemName: "star.fill")
            .font(.system(size: size, weight: .semibold))
            .foregroundColor(AppTheme.textPrimary.opacity(alpha))
            .shadow(color: AppTheme.mist.opacity(0.55), radius: 10, x: 0, y: 0)
            .offset(x: x, y: y)
            .scaleEffect(0.92 + local * 0.12)
    }
}

private struct AppCoreStar: View {
    let t: Double

    var body: some View {
        let pulse = 0.86 + 0.14 * abs(sin(t * Double.pi))
        let glow = 0.22 + 0.22 * abs(sin((t + 0.25) * Double.pi))

        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.accent.opacity(0.38 + glow),
                            AppTheme.accentSoft.opacity(0.12 + glow * 0.35),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 6,
                        endRadius: 90
                    )
                )
                .blur(radius: 10)
                .blendMode(.screen)

            Image(systemName: "star.fill")
                .font(.system(size: 46, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary.opacity(0.92))
                .shadow(color: AppTheme.mist.opacity(0.65), radius: 14, x: 0, y: 0)

            Image(systemName: "sparkle")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary.opacity(0.55))
                .offset(x: 18, y: -18)
        }
        .scaleEffect(pulse)
    }
}
