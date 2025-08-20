import SwiftUI
import AppKit

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.isMovableByWindowBackground = true
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.styleMask.insert(.fullSizeContentView)
                // Hide standard window buttons to fully remove native header UI
                [NSWindow.ButtonType.closeButton,
                 .miniaturizeButton,
                 .zoomButton,
                 .toolbarButton].forEach { type in
                    window.standardWindowButton(type)?.isHidden = true
                }
                // Disable user resizing so the window height remains adaptive to content
                window.styleMask.remove(.resizable)
                window.backgroundColor = NSColor.clear
                window.isOpaque = false
                window.hasShadow = true
                
                // Force window to adapt to content size
                window.setContentSize(window.contentView?.fittingSize ?? window.frame.size)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                window.isMovableByWindowBackground = true
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.styleMask.insert(.fullSizeContentView)
                // Hide standard window buttons to fully remove native header UI
                [NSWindow.ButtonType.closeButton,
                 .miniaturizeButton,
                 .zoomButton,
                 .toolbarButton].forEach { type in
                    window.standardWindowButton(type)?.isHidden = true
                }
                // Disable user resizing so the window height remains adaptive to content
                window.styleMask.remove(.resizable)
                window.backgroundColor = NSColor.clear
                window.isOpaque = false
                window.hasShadow = true
                
                // Force window to adapt to content size
                window.setContentSize(window.contentView?.fittingSize ?? window.frame.size)
            }
        }
    }
}


