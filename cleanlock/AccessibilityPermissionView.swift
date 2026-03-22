import SwiftUI

struct AccessibilityPermissionView: View {
    @ObservedObject var cleaningController: ScreenCleaningController

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "hand.raised.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("需要辅助功能权限")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("设置以禁用 “⌘、⌃、fn、⏻” 等按键\n防止清洁过程中误触")
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            Button("请求权限") {
                cleaningController.requestAccessibilityAccess()
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
