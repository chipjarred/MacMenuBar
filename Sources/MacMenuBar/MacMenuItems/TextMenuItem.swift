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

// -------------------------------------
public struct TextMenuItem
{
    /**
     - Parameter sender: The object that triggered the action.
     */
    public typealias ActionClosure = ClosureAction.ActionClosure
    
    public private(set) var nsMenuItem: NSMenuItem
    
    @inlinable public var action: Action
    {
        get { (nsMenuItem as? NSMacMenuItem)!._action! }
        set { (nsMenuItem as? NSMacMenuItem)!._action!  = newValue }
    }

    // -------------------------------------
    @inlinable public var keyEquivalent: KeyEquivalent
    {
        get { KeyEquivalent(from: nsMenuItem) }
        set
        {
            nsMenuItem.keyEquivalent = String(newValue.key)
            nsMenuItem.keyEquivalentModifierMask = newValue.modifiers
        }
    }
    
    // -------------------------------------
    /**
     Initializes a new MacMenuItem.  The menu item is visible and enabled by default.
     
     - Parameters:
        - title: `String` to be displayed for this menu item.
        - keyEquivalent: `String` indicating the keyboard key combination short-cut for this menu item.
        - action: Closure to be called when this menu item is selected.
     */
    // -------------------------------------
    @inlinable
    public init(
        title: String,
        keyEquivalent: KeyEquivalent = .none,
        action: @escaping ActionClosure)
    {
        self.init(
            title: title,
            action: ClosureAction(keyEquivalent: keyEquivalent, closure: action)
        )
    }
    
    // -------------------------------------
    @inlinable
    public init(
        title: String,
        keyEquivalent: KeyEquivalent,
        action: Selector)
    {
        self.init(
            title: title,
            action: SelectorAction(
                keyEquivalent: keyEquivalent,
                selector: action
            )
        )
    }
    
    // -------------------------------------
    @inlinable
    public init(action: Action)
    {
        self.init(title: "", action: action)
        canBeEnabled = true
        isVisible = true
    }
    
    // -------------------------------------
    @inlinable
    public init(title: String, action: Action = NoAction()) {
        self.init(from: NSMacMenuItem(title: title, action: action))
    }
    
    // -------------------------------------
    @inlinable
    public init(title: String, action: StandardMenuItemAction)
    {
        self.init(action: action)
        self.title = title
    }
    
    // -------------------------------------
    @usableFromInline
    internal init(from nsMacMenuItem: NSMacMenuItem) {
        self.nsMenuItem = nsMacMenuItem
    }
}

// -------------------------------------
extension TextMenuItem: ActionableMenuItem
{
    // -------------------------------------
    @inlinable public var title: String
    {
        get { nsMenuItem.title }
        set { nsMenuItem.title = newValue }
    }
}
