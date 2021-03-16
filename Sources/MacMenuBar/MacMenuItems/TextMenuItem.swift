//
//  MacMenuItem.swift
//  
//
//  Created by Chip Jarred on 2/20/21.
//

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
    public init(action: Action)
    {
        self.init(title: "", action: action)
        isEnabled = true
        isVisible = true
    }
    
    // -------------------------------------
    public init(title: String, action: Action = NoAction()) {
        self.nsMenuItem = NSMacMenuItem(title: title, action: action)
    }
    
    // -------------------------------------
    public init(title: String, action: StandardMenuItemAction)
    {
        self.init(action: action)
        self.title = title
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
