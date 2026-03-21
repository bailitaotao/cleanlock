import SwiftUI

struct CleaningOverlayView: View {
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Button("退出清洁", action: onExit)
                .buttonBorderShape(.capsule)
                .buttonStyle(.glassProminent)
                .tint(.white.opacity(0.1))
        }
    }
}
