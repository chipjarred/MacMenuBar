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
public enum MacMenuItemState: Int
{
    case mixed = -1
    case off   =  0
    case on    =  1
    
    // -------------------------------------
    @usableFromInline
    internal var nsControlStateValue: NSControl.StateValue {
        .init(self.rawValue)
    }
}

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
    @inlinable public var state: MacMenuItemState
    {
        get { MacMenuItemState(rawValue: nsMenuItem.state.rawValue)! }
        set { nsMenuItem.state = newValue.nsControlStateValue }
    }
    
    // -------------------------------------
    @inlinable public mutating func toggleState() {
        state = isChecked ? .off : .on
    }
    
    // -------------------------------------
    @inlinable public func with(state: MacMenuItemState) -> Self
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
    public func updatingStateWith(
        updater: @escaping () -> MacMenuItemState) -> Self
    {
        (self.nsMenuItem as? NSMacMenuItem)?.stateUpdater = updater
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
