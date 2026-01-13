import UIKit
import SwiftUI

final class AppFlowDelegate: NSObject, UIApplicationDelegate {

    static weak var shared: AppFlowDelegate?

    private var forcedMask: UIInterfaceOrientationMask = [.portrait]

    override init() {
        super.init()
        AppFlowDelegate.shared = self
    }

    func lockPortrait() {
        forcedMask = [.portrait]
        UIViewController.attemptRotationToDeviceOrientation()
    }

    func allowFlexible() {
        forcedMask = [.portrait, .landscapeLeft, .landscapeRight]
        UIViewController.attemptRotationToDeviceOrientation()
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        forcedMask
    }
}
