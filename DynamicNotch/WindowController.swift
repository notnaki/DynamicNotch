import SwiftUI

class NotchWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
}

class NotchWindowController: NSWindowController {
    private var isExpanded = true
    private let collapsedSize = CGSize(width: 274, height: 32)
    private let expandedSize = CGSize(width: 344, height: 135)
    private let menuBarHeight: CGFloat = 24 // Standard menu bar height
    
    convenience init(contentView: NSView) {
        let window = NotchWindow(
            contentRect: NSRect(origin: .zero, size: CGSize(width: 344, height: 135)),
            styleMask: [.borderless],
            backing: .buffered, defer: false)
        
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.level = .statusBar
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        self.init(window: window)
        self.window?.contentView = contentView
        self.window?.makeKeyAndOrderFront(nil)
        
        positionWindowAtTop(animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleWindowSize), name: Notification.Name("ToggleWindowSize"), object: nil)
    }
    
    private func positionWindowAtTop(animated: Bool) {
        guard let screen = NSScreen.main, let window = self.window else { return }
        let screenFrame = screen.frame
        let size = isExpanded ? expandedSize : collapsedSize
        
        let xPos = (screenFrame.width - size.width) / 2
        let yPos = screenFrame.height - size.height
        
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                window.animator().setFrame(NSRect(origin: CGPoint(x: xPos, y: yPos), size: size), display: true)
            })
        } else {
            window.setFrame(NSRect(origin: CGPoint(x: xPos, y: yPos), size: size), display: true)
        }
    }
    
    @objc private func toggleWindowSize() {
        isExpanded.toggle()
        animateWindowResizeAndReposition()
    }
    
    private func animateWindowResizeAndReposition() {
        guard let window = self.window, let screen = NSScreen.main else { return }
        let newSize = isExpanded ? expandedSize : collapsedSize
        let screenFrame = screen.frame
        
        let xPos = (screenFrame.width - newSize.width) / 2
        let yPos = screenFrame.height - newSize.height
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            let newOrigin = CGPoint(
                x: xPos,
                y: yPos
            )
            
            window.animator().setFrame(
                NSRect(origin: newOrigin, size: newSize),
                display: true
            )
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
