import SwiftUI
import Combine

@main
struct AppApp: App {

    @UIApplicationDelegateAdaptor(AppFlowDelegate.self) private var flow

    @StateObject private var router = AppRouter()
    @StateObject private var launch = AppLaunchStore()
    @StateObject private var session = AppSessionState()
    @StateObject private var orientation = AppOrientationManager()

    var body: some Scene {
        WindowGroup {
            AppEntryScreen()
                .environmentObject(router)
                .environmentObject(launch)
                .environmentObject(session)
                .environmentObject(orientation)
        }
    }
}
