//
//  cleanlockApp.swift
//  cleanlock
//
//  Created by Tim on 2026/3/15.
//

import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

@main
struct cleanlockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Window("Cleanlock", id: "main") {
            RootView()
        }
        .windowResizability(.contentSize)
    }
}
