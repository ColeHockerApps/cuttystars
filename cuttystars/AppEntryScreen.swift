import SwiftUI
import Combine

struct AppEntryScreen: View {

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var launch: AppLaunchStore
    @EnvironmentObject private var session: AppSessionState
    @EnvironmentObject private var orientation: AppOrientationManager

    @State private var showLoading: Bool = true
    @State private var minTimePassed: Bool = false
    @State private var surfaceReady: Bool = false
    @State private var pendingPoint: URL? = nil
    @State private var didApplyOrientationRule: Bool = false

    var body: some View {
        ZStack {
            AppPlayContainer {
                surfaceReady = true
                applyOrientationIfPossible()
                tryFinishLoading()
            }
            .opacity(showLoading ? 0 : 1)
            .animation(.easeOut(duration: 0.35), value: showLoading)

            if showLoading {
                AppLoadingScreen()
                    .transition(.opacity)
            }
        }
        .onAppear {
            orientation.allowFlexible()

            showLoading = true
            minTimePassed = false
            surfaceReady = false
            pendingPoint = nil
            didApplyOrientationRule = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                minTimePassed = true
                applyOrientationIfPossible()
                tryFinishLoading()
            }
        }
        .onReceive(orientation.$activeValue) { next in
            pendingPoint = next
            applyOrientationIfPossible()
        }
    }

    private func applyOrientationIfPossible() {
        guard didApplyOrientationRule == false else { return }
        guard minTimePassed && surfaceReady else { return }
        guard let next = pendingPoint else { return }

        if isSame(next, launch.mainPoint) {
            AppFlowDelegate.shared?.lockPortrait()
        } else {
            AppFlowDelegate.shared?.allowFlexible()
        }

        didApplyOrientationRule = true
    }

    private func tryFinishLoading() {
        guard minTimePassed && surfaceReady else { return }
        withAnimation(.easeOut(duration: 0.35)) {
            showLoading = false
        }
    }

    private func isSame(_ a: URL, _ b: URL) -> Bool {
        normalize(a) == normalize(b)
    }

    private func normalize(_ u: URL) -> String {
        var s = u.absoluteString
        while s.count > 1, s.hasSuffix("/") { s.removeLast() }
        return s
    }
}
