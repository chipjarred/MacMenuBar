// Copyright 2021 Chip Jarred
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Cocoa
import SwiftUI
import MacMenuBar

// -------------------------------------
class AppDelegate: NSObject, NSApplicationDelegate
{
    static var shared: AppDelegate { NSApp.delegate! as! AppDelegate }
    
    internal let userDefaultsSuite = "com.github.chipjarred.MacMenuBar."
        + "\(ProcessInfo.processInfo.processName)"

    var window: NSWindow!
    var gameWindowDelegate: GameWindowDelegate!
    var gameHostingView: NSGameHostingView!
    var puzzle: PuzzleObject!
    var sheetRequest = SheetRequest()
    var prefs: Preferences!

    // -------------------------------------
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        MacMenuBar.debugPrintMenuInsertionRefusals = false
        
        loadPreferences()
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(
            sheetRequest: sheetRequest,
            prefs: prefs
        )
        
        puzzle = contentView.puzzle
        gameHostingView = NSGameHostingView(rootView: contentView)

        // Create the window and set the content view.
        window = NSGameWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = gameHostingView
        window.makeKeyAndOrderFront(nil)
        updateWindowTitle(with: puzzle.name)
        
        gameWindowDelegate = GameWindowDelegate(window)
        window.delegate = gameWindowDelegate
        
        Self.initializeFullScreenDetection()
        setMenuBar(to: MainMenuBar())
        
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(self.handleSystemUIAppearanceChange(notification:)),
            name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"),
            object: nil
        )
    }
    
    // -------------------------------------
    public func updateWindowTitle(with name: String) {
        window.title = "\(ProcessInfo.processInfo.processName): \(name)"
    }
    
    // -------------------------------------
    @objc func openDocument(_: Any?)
    {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        if panel.directoryURL == nil {
            panel.directoryURL = puzzle.directoryURL
        }
        panel.allowedFileTypes = [puzzle.fileExtension]
        panel.beginSheetModal(for: window)
        { response in
            if response == .OK { self.puzzle.load(from: panel) }
        }
    }
    
    // -------------------------------------
    @objc func save(_ sender: Any?)
    {
        if let bookmark = puzzle.bookmark {
            puzzle.save(to: bookmark)
        }
        else { saveTo(sender) }
    }
    
    // -------------------------------------
    @objc func saveTo(_: Any?)
    {
        let panel = NSSavePanel()
        panel.title = "Save Sudoku Game"
        panel.nameFieldLabel = "Save game as:"
        panel.nameFieldStringValue = puzzle.name
        panel.canCreateDirectories = true
        panel.directoryURL = puzzle.directoryURL
        panel.allowedFileTypes = [puzzle.fileExtension]
        panel.isExtensionHidden = true
        panel.beginSheetModal(for: window)
        { response in
            panel.orderOut(self)
            if response == .OK { self.puzzle.save(from: panel) }
        }
    }
    
    // -------------------------------------
    func errorAlert(_ message: String, moreText: String = "")
    {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = message
        alert.informativeText = moreText
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: window) {_ in  }
    }

    // -------------------------------------
    // We have to respond to this so command-. will work on cancel buttons.
    @objc func cancelOperation(_ sender: Any?)
    {
        let event = CGEvent(
            keyboardEventSource: nil,
            virtualKey: .kVK_ANSI_Period,
            keyDown: true
        )!
        _ = KeyResponder.current?.closure?(NSEvent(cgEvent: event)!)
    }
    
    // -------------------------------------
    func newGame()
    {
        if puzzle.hasStarted {
            sheetRequest.state = .newGame
        }
        else { puzzle.newPuzzle()  }
    }
    
    // -------------------------------------
    @objc func handleSystemUIAppearanceChange(notification: Any?) {
        Preferences.shared.updateSystemTheme()
    }

    // -------------------------------------
    func applicationWillTerminate(_ aNotification: Notification) {
        savePreferences()
    }

    // -------------------------------------
    func savePreferences()
    {
        if let prefsData = try? JSONEncoder().encode(prefs) {
            UserDefaults.standard.setValue(prefsData, forKey: "Preferences")
        }
        
        UserDefaults.standard.synchronize()
    }
    
    // -------------------------------------
    func loadPreferences()
    {
        if let prefsData = UserDefaults.standard.data(forKey: "Preferences"),
           let t = try? JSONDecoder().decode(Preferences.self, from: prefsData)
        {
            prefs = t
        }
        else { prefs = Preferences() }
    }
    
    // -------------------------------------
    @objc func undo() {
        puzzle.undo()
    }
    
    // -------------------------------------
    @objc func redo() {
        puzzle.redo()
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
