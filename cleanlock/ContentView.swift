//
//  ContentView.swift
//  cleanlock
//
//  Created by Tim on 2026/3/15.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var cleaningController: ScreenCleaningController
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "macbook")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("屏幕清洁模式")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("开启后屏幕将变黑并屏蔽键盘按键\n方便你清洁屏幕与键盘")
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                cleaningController.startCleaning()
            }) {
                Text("开启清洁")
                    .fontWeight(.medium)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 6)
            }
            .controlSize(.large)
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.capsule)
            .disabled(cleaningController.isCleaning)
        }
        .padding(40)
        // 限制主窗口的最小尺寸，防止用户缩得太小
        .frame(minWidth: 400, minHeight: 300)
        .toolbar(removing: .title)
    }
}

#Preview {
    ContentView(cleaningController: ScreenCleaningController())
}
