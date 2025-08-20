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
                // Disable user resizing entirely
                window.styleMask.remove(.resizable)
                window.standardWindowButton(.zoomButton)?.isEnabled = false
                window.backgroundColor = NSColor.clear
                window.isOpaque = false
                window.hasShadow = true
                
                // Force window to adapt to content size and lock min/max
                let size = window.contentView?.fittingSize ?? window.frame.size
                window.setContentSize(size)
                window.minSize = size
                window.maxSize = size
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

                // Disable user resizing entirely
                window.styleMask.remove(.resizable)
                window.standardWindowButton(.zoomButton)?.isEnabled = false
                window.backgroundColor = NSColor.clear
                window.isOpaque = false
                window.hasShadow = true
                
                // Force window to adapt to content size and lock min/max
                let size = window.contentView?.fittingSize ?? window.frame.size
                window.setContentSize(size)
                window.minSize = size
                window.maxSize = size
            }
        }
    }
}


