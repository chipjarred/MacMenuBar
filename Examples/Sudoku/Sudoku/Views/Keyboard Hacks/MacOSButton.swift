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

import SwiftUI
import MacMenuBar

// -------------------------------------
/*
 Makes a traditional macOS-style button that can have a key equivalent.  If
 that key equivalent is "\r" with no modifiers, the button is the
 "default button" indicated by the traditional highlight.
 */
struct MacOSButton: NSViewRepresentable
{
    typealias NSViewType = NSClosureButton

    let title: String
    let action: () -> Void
    let keyEquivalent: KeyEquivalent?

    // -------------------------------------
    init(
        _ title: String,
        keyEquivalent: KeyEquivalent? = nil,
        action: @escaping () -> Void)
    {
        self.title = title
        self.keyEquivalent = keyEquivalent
        self.action = action
    }

    // -------------------------------------
    func makeNSView(context: Context) -> NSClosureButton
    {
        let button = NSClosureButton(
            title,
            keyEquivalent: keyEquivalent,
            action: action
        )
        
        if keyEquivalent != nil && keyEquivalent! != .none
        {
            if let currentResponder = KeyResponder.current
            {
                currentResponder.onKeyDown {
                    button.keyDown($0)
                }
            }
            else
            {
                #if DEBUG
                print("No keyresponder is set!")
                #endif
            }
        }
        
        return button
    }

    // -------------------------------------
    func updateNSView(_ nsView: NSClosureButton, context: Context) {
        return
    }
}


// -------------------------------------
@objc class NSClosureButton: NSButton
{
    let buttonAction: () -> Void

    // -------------------------------------
    init(
        _ title: String,
        keyEquivalent: KeyEquivalent?,
        action: @escaping () -> Void)
    {
        self.buttonAction = action
        super.init(frame: .zero)
        self.title = title
        self.action = #selector(buttonDown(_:))
        self.target = self
        self.focusRingType = .none
        self.bezelStyle = .rounded
        if let keyEquiv = keyEquivalent
        {
            self.keyEquivalent = String(keyEquiv.key)
            self.keyEquivalentModifierMask = keyEquiv.modifiers
            if keyEquiv.description == "\r" && keyEquiv.modifiers.isEmpty {
                self.isBordered = true
            }
        }
    }

    // -------------------------------------
    required init?(coder: NSCoder) {
        fatalError("Unimplemented")
    }

    // -------------------------------------
    @objc func buttonDown(_ sender: Any?) {
        buttonAction()
    }
    
    // -------------------------------------
    override func responds(to aSelector: Selector!) -> Bool
    {
        if aSelector == #selector(cancelOperation(_:)) {
            return isCancelButton
        }
        return super.responds(to: aSelector)
    }
    
    // -------------------------------------
    override func cancelOperation(_ sender: Any?)
    {
        if isCancelButton {
            buttonAction()
        }
    }
    
    // -------------------------------------
    var isCancelButton: Bool
    {
        return self.keyEquivalent == "."
            && self.keyEquivalentModifierMask == .command
    }
    
    // -------------------------------------
    func keyDown(_ event: NSEvent) -> Bool
    {
        guard event.matches(for: self) else { return false }
        
        super.performClick(self)
        return true
    }
}
