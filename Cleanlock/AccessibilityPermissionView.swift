import SwiftUI

struct AccessibilityPermissionView: View {
    @ObservedObject var cleaningController: ScreenCleaningController

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "hand.raised.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text(.permissionTitle)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(.permissionSubtitle)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            Button {
                cleaningController.requestAccessibilityAccess()
            } label: {
                Text(.permissionRequest)
            }
            .controlSize(.large)
            .buttonStyle(.glass)
            .buttonBorderShape(.capsule)
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 300)
        .toolbar(removing: .title)
    }
}

#Preview {
    AccessibilityPermissionView(cleaningController: ScreenCleaningController())
}
