import SwiftUI

struct RootView: View {
    @StateObject private var cleaningController = ScreenCleaningController()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if cleaningController.hasAccessibilityAccess {
                ContentView(cleaningController: cleaningController)
            } else {
                AccessibilityPermissionView(cleaningController: cleaningController)
            }
        }
        .onAppear {
            cleaningController.refreshAccessibilityAccessStatus()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            cleaningController.refreshAccessibilityAccessStatus()
        }
    }
}

#Preview {
    RootView()
}
