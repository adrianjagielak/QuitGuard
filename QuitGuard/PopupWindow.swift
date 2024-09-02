//
//  PopupWindow.swift
//  QuitGuard
//
//  Created by Adrian Jagielak on 02/09/2024.
//

import Foundation
import SwiftUI

class PopupWindowController: NSWindowController {
    private var contentView: NSHostingView<PopupContentView>
    private var isShowing = false
    public private(set) var popupState = PopupState.hidden

    init() {
        let popupContentView = PopupContentView(popupState: popupState)
        contentView = NSHostingView(rootView: popupContentView)

        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 150),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        window.isReleasedWhenClosed = false
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.ignoresMouseEvents = true
        window.center()

        window.contentView = contentView

        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func showPopup() {
        if !isShowing {
            window?.orderFrontRegardless()
            isShowing = true
        }
    }

    private func hidePopup() {
        if isShowing {
            window?.orderOut(nil)
            isShowing = false
        }
    }

    func updatePopupState(_ popupState: PopupState) {
        self.popupState = popupState

        switch popupState {
        case .hidden:
            hidePopup()
        case .countdown(_), .aborted, .finished:
            showPopup()
        }

        contentView.rootView = PopupContentView(popupState: popupState)
    }
}

struct PopupContentView: View {
    let popupState: PopupState

    var message: String {
        switch popupState {
        case .hidden:
            ""
        case let .countdown(int):
            "Hold Cmd+Q to quit: \(int)..."
        case .aborted:
            "Cmd+Q blocked.\nPress and hold Cmd+Q to try again."
        case .finished:
            "Cmd+Q confirmed. Quitting..."
        }
    }

    var body: some View {
        VStack {
            Text(message)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(width: 350, height: 150)
        .background(VisualEffectBlur(material: .popover))
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
    }
}

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material

    func makeNSView(context _: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_: NSVisualEffectView, context _: Context) {}
}
