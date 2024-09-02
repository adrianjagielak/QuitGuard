//
//  AccessibilityPermissionChecker.swift
//  QuitGuard
//
//  Created by Adrian Jagielak on 02/09/2024.
//

import Combine
import Foundation
import SwiftUI

class AccessibilityPermissionChecker: ObservableObject {
    @Published var hasAXPermission: Bool = false

    private var cancellable: AnyCancellable?

    var cmdQInterceptor = CmdQInterceptor()
    @Published var errorMessage: String?

    init() {
        // Start monitoring AX permission status continuously
        startMonitoring()
    }

    private func startMonitoring() {
        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkAXPermission()
            }
    }

    private func checkAXPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: false]
        let isTrusted = AXIsProcessTrustedWithOptions(options)

        if isTrusted {
            stopMonitoring()
            DispatchQueue.main.async {
                self.errorMessage = self.cmdQInterceptor.startEventTap()
            }
        }

        if isTrusted != hasAXPermission {
            DispatchQueue.main.async {
                self.hasAXPermission = isTrusted
            }
        }
    }

    private func stopMonitoring() {
        cancellable?.cancel()
        cancellable = nil
    }
}
