//
//  MacMenuItem.swift
//  
//
//  Created by Chip Jarred on 2/20/21.
//

import Cocoa

// -------------------------------------
public protocol MacMenuItem: MenuElement
{
    var nsMenuItem: NSMenuItem { get }
}

// -------------------------------------
extension MacMenuItem
{
    @inlinable public var isItem: Bool { true }
    
    // -------------------------------------
    @inlinable public var isChecked: Bool
    {
        get { state != .off }
        set { state = newValue ? .on : .off }
    }
    
    // -------------------------------------
    @inlinable public var state: NSControl.StateValue
    {
        get { nsMenuItem.state }
        set { nsMenuItem.state = newValue }
    }
    
    // -------------------------------------
    @inlinable public mutating func toggleState() {
        state = isChecked ? .off : .on
    }
    
    // -------------------------------------
    @inlinable public func with(state: NSControl.StateValue) -> Self
    {
        var changedItem = self
        changedItem.state = state
        return changedItem
    }
    
    // -------------------------------------
    @inlinable public func checked(_ status: Bool = true) -> Self
    {
        var changedItem = self
        changedItem.isChecked = status
        return changedItem
    }
    
    // -------------------------------------
    @inlinable
    public func toggleStateWhenSelected(_ toggle: Bool = true) -> Self
    {
        (self.nsMenuItem as? NSMacMenuItem)?.toggleStateWhenSelected =
            toggle
        return self
    }
    
    // -------------------------------------
    @inlinable
    public func indented(level: Int = 1) -> Self
    {
        nsMenuItem.indentationLevel = level
        return self
    }

    // -------------------------------------
    @inlinable
    public func appendSelf<T: MacMenu>(to menu: inout T) {
        menu.append(item: self)
    }
}
