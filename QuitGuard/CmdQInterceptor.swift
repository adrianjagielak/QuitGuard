//
//  CmdQInterceptor.swift
//  QuitGuard
//
//  Created by Adrian Jagielak on 02/09/2024.
//

import Combine
import SwiftUI

enum PopupState {
    case hidden
    case countdown(Int)
    case aborted
    case finished
}

class CmdQInterceptor {
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    var eventTap: CFMachPort?
    private var hideAbortedJob: DispatchWorkItem?
    private var isCmdQActive = false
    private var keyUpCleared = true

    private var popupWindowController: PopupWindowController?

    func startCountdown() {
        guard timer == nil else { return }
        guard keyUpCleared else { return }

        if popupWindowController == nil {
            popupWindowController = PopupWindowController()
        }

        keyUpCleared = false

        hideAbortedJob?.cancel()

        popupWindowController!.updatePopupState(.countdown(3))

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }

                switch popupWindowController!.popupState {
                case let .countdown(seconds):
                    if seconds > 1 {
                        popupWindowController!.updatePopupState(.countdown(seconds - 1))
                    } else {
                        timer?.cancel()
                        timer = nil
                        popupWindowController!.updatePopupState(.finished)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.popupWindowController!.updatePopupState(.hidden)
                        }
                        triggerCmdQ()
                    }

                case .hidden, .aborted, .finished:
                    timer?.cancel()
                    timer = nil
                }
            }
    }

    func abortCountdown() {
        keyUpCleared = true

        if timer != nil {
            DispatchQueue.main.async {
                self.abortTimer()
            }
        }
    }

    func abortTimer() {
        popupWindowController!.updatePopupState(.aborted)
        timer?.cancel()
        timer = nil

        hideAbortedJob = DispatchWorkItem {
            if case .aborted = self.popupWindowController!.popupState {
                self.popupWindowController!.updatePopupState(.hidden)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: hideAbortedJob!)
    }

    func triggerCmdQ() {
        let source = CGEventSource(stateID: .hidSystemState)

        let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 12, keyDown: true)
        keyDownEvent?.flags.insert(.maskCommand)
        keyDownEvent?.setIntegerValueField(.eventSourceUserData, value: 69)
        keyDownEvent?.post(tap: .cghidEventTap)

        let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 12, keyDown: false)
        keyUpEvent?.flags.insert(.maskCommand)
        keyUpEvent?.setIntegerValueField(.eventSourceUserData, value: 69)
        keyUpEvent?.post(tap: .cghidEventTap)
    }

    func startEventTap() -> String? {
        guard eventTap == nil else { return nil }

        let eventMask: CGEventMask =
            1 << CGEventType.keyDown.rawValue |
            1 << CGEventType.keyUp.rawValue

        let eventCallback: CGEventTapCallBack = { proxy, type, event, refcon in
            guard let refcon else { return Unmanaged.passRetained(event) }
            let interceptor = Unmanaged<CmdQInterceptor>.fromOpaque(refcon).takeUnretainedValue()
            return interceptor.handleEvent(proxy: proxy, type: type, event: event)
        }

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: eventCallback,
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )

        guard let eventTap else {
            return "Failed starting Cmd+Q interceptor"
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        return nil
    }

    func stopEventTap() {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
        }
    }

    func handleEvent(proxy _: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard event.getIntegerValueField(.keyboardEventKeycode) == 12 else {
            return Unmanaged.passRetained(event)
        }

        guard event.getIntegerValueField(.eventSourceUserData) != 69 else {
            return Unmanaged.passRetained(event)
        }

        let isCmdPressed = event.flags.contains(.maskCommand)

        if type == .keyDown, isCmdPressed {
            // Cmd+Q keyDown
            isCmdQActive = true
            DispatchQueue.main.async {
                self.startCountdown()
            }
            return nil
        } else if type == .keyUp, isCmdQActive {
            // Cmd+Q keyUp
            isCmdQActive = false
            DispatchQueue.main.async {
                self.abortCountdown()
            }
            return nil
        }

        return Unmanaged.passRetained(event)
    }
}
