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

public var debugPrintMenuInsertionRefusals = true

// -------------------------------------
@objc fileprivate extension NSMenu {
    @objc var nsMacMenuItem: NSMacMenuItem? { return nil }
}

// -------------------------------------
public class NSMacMenu: NSMenu, NSMenuDelegate
{
    public typealias ActionClosure = TextMenuItem.ActionClosure
    
    // -------------------------------------
    public override var title: String
    {
        get { return super.title }
        set
        {
            let newValue = substituteVariables(in: localize(newValue))
            _nsMacMenuItem?.title = newValue
            super.title = newValue
        }
    }
    
    // -------------------------------------
    public var isHidden: Bool
    {
        get { return _nsMacMenuItem?.isHidden ?? false }
        set { _nsMacMenuItem?.isHidden = newValue }
    }
    
    // -------------------------------------
    public var isEnabled: Bool
    {
        get { return _nsMacMenuItem?.isEnabled ?? true }
        set { _nsMacMenuItem?.isEnabled = newValue }
    }
    
    @usableFromInline
    internal var refuseAutoinjectedItems = false
    
    internal var dynamicContent = DynamicNSMenuContent()
    internal var rebuilding = false

    private weak var _nsMacMenuItem: NSMacMenuItem? = nil
    
    @usableFromInline
    @objc override var nsMacMenuItem: NSMacMenuItem? { return _nsMacMenuItem }
    
    // -------------------------------------
    public override init(title: String)
    {
        super.init(title: substituteVariables(in: localize(title)))
        self.delegate = self
    }
    
    // -------------------------------------
    required init(coder: NSCoder)
    {
        super.init(coder: coder)
        self.delegate = self
    }
    
    // MARK:- Adding menu items
    // -------------------------------------
    public func addItem(
        withTitle title: String,
        action: Action? = nil)
    {
        let item = NSMacMenuItem(title: title, action: action)
        addItem(item)
    }
    
    // -------------------------------------
    public override func addItem(_ item: NSMenuItem) {
        insertItem(item, at: items.count)
    }
    
    // -------------------------------------
    /*
     We don't call this, but macOS's automatically added items do. We create
     the item to placate macOS', but for that we use the standard NSMenuItem
     instead of NSMacMenuItem, so we can filter it out if we've already
     implemented the specified selector.
     */
    public override func addItem(
        withTitle string: String,
        action selector: Selector?,
        keyEquivalent charCode: String) -> NSMenuItem
    {
        let item = NSMenuItem(
            title: string,
            action: selector,
            keyEquivalent: charCode)
        
        addItem(item)
        return item
    }
    
    // MARK:- Inserting menu items
    // -------------------------------------
    public func insertItem(
        withTitle title: String,
        action: Action? = nil,
        atIndex index: Int)
    {
        let item = NSMacMenuItem(title: title, action: action)
        insertItem(item, at: index)
    }
    
    // -------------------------------------
    public override func insertItem(_ item: NSMenuItem, at index: Int)
    {
        /**
         If you are having problems with auto-injected items inappropriately
         duplicating items that you've created, or get an assertion from within
         `NSMenu`'s `insertItem` that the item has already been added, use the
         `refuseAutoinjectedMenuItems` property of `MacMenu`, and implement an
         item for that action yourself.
         
         For convenience, `StandardMenuItemActions` defines actions for the
         auto-injected items at the time of writing this comment.  If new ones
         are added before `StandardMenuItemActions` can be updated to include
         them, the debugging output below prints the selector, to help you use
         `SelectorAction` to implement it.
         */
        if refuseAutoinjectedItems && !(item is NSMacMenuItem)
        {
            #if DEBUG
            if debugPrintMenuInsertionRefusals
            {
                print(
                    "Refusing to insert macOS auto-injected NSMenuItem named "
                    + "\"\(item.title)\" using action selector, "
                    + "\(String(describing: item.action)), at position \(index). "
                    + " Consider implementing it yourself."
                )
                print(
                    "To silence these messages, "
                    + "MacMenuBar.debugPrintMenuInsertionRefusals = false"
                )
            }
            #endif
        }
        else if rebuilding
        {
            if !items.contains(where: { $0 === item } ) {
                super.insertItem(item, at: items.count)
            }
            else
            {
                #if DEBUG
                if debugPrintMenuInsertionRefusals
                {
                    print(
                        "Refusing to insert macOS auto-injected NSMenuItem named "
                        + "\"\(item.title)\" using action selector, "
                        + "\(String(describing: item.action)), at position \(index). "
                        + " Consider implementing it yourself."
                    )
                    print(
                        "To silence these messages, "
                        + "MacMenuBar.debugPrintMenuInsertionRefusals = false"
                    )
                }
                #endif
            }
        }
        else { dynamicContent.append(item) }
    }
    
    // -------------------------------------
    /*
     We don't call this, but macOS's automatically added items do. We create
     the item to placate macOS', but for that we use the standard NSMenuItem
     instead of NSMacMenuItem, so we can filter it out if we've already
     implemented the specified selector.
     */
    public override func insertItem(
        withTitle string: String,
        action selector: Selector?,
        keyEquivalent charCode: String,
        at index: Int) -> NSMenuItem
    {
        let item = NSMenuItem(
            title: string,
            action: selector,
            keyEquivalent: charCode)
        
        addItem(item)
        return item
    }

    // MARK:- Adding/inserting submenus
    // -------------------------------------
    public func addSubmenu(_ subMenu: NSMacMenu) {
        addItem(wrap(subMenu: subMenu))
    }
    
    // -------------------------------------
    public func insertSubmenu(_ subMenu: NSMacMenu, at index: Int) {
        insertItem(wrap(subMenu: subMenu), at: index)
    }
    
    // -------------------------------------
    public func removeSubmenu(_ subMenu: NSMacMenu)
    {
        if let wrapper = subMenu.nsMacMenuItem {
            removeItem(wrapper)
        }
    }
    
    // -------------------------------------
    fileprivate func wrap(subMenu: NSMacMenu) -> NSMacMenuItem
    {
        let item = NSMacMenuItem(title: substituteVariables(in: subMenu.title))
        item.submenu = subMenu
        subMenu._nsMacMenuItem = item
        
        return item
    }
    
    // -------------------------------------
    public func menu(
        _ menu: NSMenu,
        update item: NSMenuItem,
        at index: Int,
        shouldCancel: Bool) -> Bool
    {
        if let item = item as? NSMacMenuItem
        {
            item.title = item.titleUpdater?() ?? item.title
            item.state = item.stateUpdater?().nsControlStateValue ?? item.state
        }
        return true
    }
    
    // -------------------------------------
    public func numberOfItems(in menu: NSMenu) -> Int
    {
        dynamicContent.rebuild(for: self)
        return items.count
    }
}
