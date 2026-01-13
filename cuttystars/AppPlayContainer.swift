import SwiftUI
import Combine

struct AppPlayContainer: View {

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var launch: AppLaunchStore
    @EnvironmentObject private var session: AppSessionState

    @StateObject private var model = AppPlayContainerModel()

    let onReady: () -> Void

    init(onReady: @escaping () -> Void) {
        self.onReady = onReady
    }

    var body: some View {
        let startPoint = launch.restoreResume() ?? launch.mainPoint

        ZStack {
            Color.black.ignoresSafeArea()

            AppPlayView(
                startPoint: startPoint,
                launch: launch,
                session: session
            ) {
                model.markReady()
                onReady()
            }
            .opacity(model.fadeIn ? 1 : 0)
            .animation(.easeOut(duration: 0.32), value: model.fadeIn)

            if model.isReady == false {
                AppLoadingScreen()
            }

            Color.black
                .opacity(model.dimLayer)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.22), value: model.dimLayer)
        }
        .onAppear {
            model.onAppear()
        }
    }
}

@MainActor
final class AppPlayContainerModel: ObservableObject {

    @Published var isReady: Bool = false
    @Published var fadeIn: Bool = false
    @Published var dimLayer: Double = 1.0

    func onAppear() {
        isReady = false
        fadeIn = false
        dimLayer = 1.0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { [weak self] in
            self?.dimLayer = 0.0
        }
    }

    func markReady() {
        guard isReady == false else { return }
        isReady = true
        fadeIn = true
    }
}
