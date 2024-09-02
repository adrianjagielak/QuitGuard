//
//  LaunchAtLoginCheckbox.swift
//  QuitGuard
//
//  Created by Adrian Jagielak on 02/09/2024.
//

import Foundation
import ServiceManagement
import SwiftUI

struct LaunchAtLoginCheckbox: View {
    @State var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        Toggle(isOn: $launchAtLogin) {
            Text("Launch at Login")
        }
        .toggleStyle(.checkbox)
        .onChange(of: launchAtLogin) { newValue in
            if newValue {
                do {
                    try SMAppService.mainApp.register()
                } catch {
                    print("Unable to register launch agent: \(error)")
                }
            } else {
                do {
                    try SMAppService.mainApp.unregister()
                } catch {
                    print("Unable to unregister launch agent: \(error)")
                }
            }
        }
    }
}
