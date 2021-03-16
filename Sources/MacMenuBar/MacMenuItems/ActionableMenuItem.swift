//
//  ActionableMenuItem.swift
//  
//
//  Created by Chip Jarred on 2/23/21.
//

import Cocoa

// -------------------------------------
public protocol ActionableMenuItem: MacMenuItem
{
    var keyEquivalent: KeyEquivalent { get set }
    var action: Action { get set }
    
    init(action: Action)
}

// -------------------------------------
extension ActionableMenuItem
{
    init(action: StandardMenuItemAction)
    {
        let (selector, keyEquivalent) = action.selectorAndKeyEquivalent
        self.init(
            action: SelectorAction(
                keyEquivalent: keyEquivalent,
                selector: selector
            )
        )
    }
    
    // -------------------------------------
    init(
        keyEquivalent: KeyEquivalent = .none,
        action: @escaping ClosureAction.ActionClosure)
    {
        self.init(action: ClosureAction(action))
        self.keyEquivalent = keyEquivalent
    }
    
    // -------------------------------------
    @inlinable public var isVisible: Bool
    {
        get { !nsMenuItem.isHidden }
        set { nsMenuItem.isHidden = !newValue }
    }
    
    // -------------------------------------
    @inlinable public var isEnabled: Bool
    {
        get { !nsMenuItem.isEnabled }
        set { nsMenuItem.isEnabled = newValue }
    }
    
    // -------------------------------------
    @inlinable public func enabled(_ enable: Bool = true) -> Self
    {
        var item = self
        item.isEnabled = enable
        return item
    }
    
    // -------------------------------------
    @inlinable public func visible(_ makeVisible: Bool = true) -> Self
    {
        var item = self
        item.isVisible = makeVisible
        return item
    }
    
    // -------------------------------------
    @inlinable public func beforeAction(
        do code: @escaping (NSMenuItem) -> Void) -> Self
    {
        if let item = nsMenuItem as? NSMacMenuItem {
            item.preActionClosure = code
        }
        
        return self
    }
    
    // -------------------------------------
    @inlinable public func afterAction(
        do code: @escaping (NSMenuItem) -> Void) -> Self
    {
        if let item = nsMenuItem as? NSMacMenuItem {
            item.postActionClosure = code
        }
        
        return self
    }
}
