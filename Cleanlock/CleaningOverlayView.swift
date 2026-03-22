import SwiftUI

struct CleaningOverlayView: View {
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Button(action: onExit) {
                Text(.overlayExit)
            }
                .buttonBorderShape(.capsule)
                .buttonStyle(.glassProminent)
                .tint(.white.opacity(0.1))
        }
    }
}
