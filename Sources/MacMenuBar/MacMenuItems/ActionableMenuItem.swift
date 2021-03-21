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
public protocol ActionableMenuItem: MacMenuItem
{
    var keyEquivalent: KeyEquivalent { get set }
    var action: Action { get set }
    
    init(action: Action)
}

// -------------------------------------
extension ActionableMenuItem
{
    public init(action: StandardMenuItemAction)
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
    public init(
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
    @inlinable public var canBeEnabled: Bool
    {
        get { (nsMenuItem as? NSMacMenuItem)?.canBeEnabled ?? true }
        set { (nsMenuItem as? NSMacMenuItem)?.canBeEnabled = newValue }
    }
    
    // -------------------------------------
    @inlinable public var isEnabled: Bool { nsMenuItem.isEnabled }

    // -------------------------------------
    @inlinable public func enabled(_ enable: Bool = true) -> Self
    {
        var item = self
        item.canBeEnabled = enable
        return item
    }
    
    // -------------------------------------
    @inlinable public func enabledWhen(
        _ validator: @escaping () -> Bool) -> Self
    {
        if let item = nsMenuItem as? NSMacMenuItem {
            item.enabledValidator = validator
        }
        return self
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
    
    // -------------------------------------
    @inlinable public func updatingTitleWith(
        _ updater: @escaping () -> String) -> Self
    {
        if let item = nsMenuItem as? NSMacMenuItem {
            item.titleUpdater = updater
        }
        return self
    }
}
