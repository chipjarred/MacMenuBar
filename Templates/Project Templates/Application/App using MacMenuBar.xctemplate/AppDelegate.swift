import Cocoa
import SwiftUI
import MacMenuBar

class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        Self.initializeFullScreenDetection()
        setMenuBar(to: MainMenuBar())
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    fileprivate static var fullScreenDetectionNeedsInitialization = true
    fileprivate static var fullScreenLock = os_unfair_lock()
    internal fileprivate(set) static var isFullScreen: Bool = false

    // -------------------------------------
    internal static func initializeFullScreenDetection()
    {
        guard fullScreenDetectionNeedsInitialization else { return }
        defer { fullScreenDetectionNeedsInitialization = false }
        
        _ = NotificationCenter.default.addObserver(
            forName: NSWindow.willEnterFullScreenNotification,
            object: nil,
            queue: nil)
        { _ in
            fullScreenLock.withLock  { isFullScreen = true }
        }
        _ = NotificationCenter.default.addObserver(
            forName: NSWindow.willExitFullScreenNotification,
            object: nil,
            queue: nil)
        { _ in
            fullScreenLock.withLock  { isFullScreen = false }
        }
    }
}

// -------------------------------------
fileprivate extension os_unfair_lock
{
    mutating func withLock<R>(block: () throws -> R) rethrows -> R
    {
        os_unfair_lock_lock(&self)
        defer { os_unfair_lock_unlock(&self) }
        
        return try block()
    }
}
