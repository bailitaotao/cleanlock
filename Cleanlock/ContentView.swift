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
                Text(.homeTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(.homeSubtitle)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                cleaningController.startCleaning()
            }) {
                Text(.homeStartCleaning)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 6)
            }
            .controlSize(.regular)
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

#Preview("English") {
    ContentView(cleaningController: ScreenCleaningController())
        .environment(\.locale, Locale(identifier: "en"))
}

#Preview("简体中文") {
    ContentView(cleaningController: ScreenCleaningController())
        .environment(\.locale, Locale(identifier: "zh-Hans"))
}

#Preview("日本語") {
    ContentView(cleaningController: ScreenCleaningController())
        .environment(\.locale, Locale(identifier: "ja"))
}

