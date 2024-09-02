//
//  ContentView.swift
//  QuitGuard
//
//  Created by Adrian Jagielak on 02/09/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var axChecker: AccessibilityPermissionChecker

    var stateMessage: String {
        if !axChecker.hasAXPermission {
            "not running"
        } else if let errorMessage = axChecker.errorMessage {
            "Error: \(errorMessage)"
        } else {
            "running"
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("QuitGuard state: \(stateMessage)")
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(.top)
            .padding(.leading)
            .padding(.trailing)

            if !axChecker.hasAXPermission {
                Text("Please accept the popup to grant Accessibility permissions.")
                    .padding(.top)
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.bottom)

                Text("If nothing happens, please open Settings -> Security & Privacy -> Privacy -> Accessibility and grant the permission manually.")
                    .font(.footnote)
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.bottom)
            } else {
                LaunchAtLoginCheckbox()
                    .padding(.top)
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.bottom)
            }
        }
    }
}
