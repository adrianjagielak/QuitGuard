//
//  QuitGuardApp.swift
//  QuitGuard
//
//  Created by Adrian Jagielak on 02/09/2024.
//

import SwiftUI

@main
struct QuitGuardApp: App {
    @StateObject private var accessibilityPermissionChecker = AccessibilityPermissionChecker()

    @State var hasStarted = false

    func start() {
        DispatchQueue.main.async {
            guard !hasStarted else { return }
            hasStarted = true

            let _ = accessibilityPermissionChecker.cmdQInterceptor.startEventTap()
        }
    }

    var body: some Scene {
        let _ = start()

        MenuBarExtra("QuitGuard", systemImage: "shield") {
            ContentView()
                .environmentObject(accessibilityPermissionChecker)
        }
        .menuBarExtraStyle(.window)
    }
}
