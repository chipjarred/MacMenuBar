//
//  NSMacMenu.swift
//  
//
//  Created by Chip Jarred on 2/19/21.
//

import Cocoa

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

    private weak var _nsMacMenuItem: NSMacMenuItem? = nil
    
    @usableFromInline
    @objc override var nsMacMenuItem: NSMacMenuItem? { return _nsMacMenuItem }
    
    // -------------------------------------
    public override init(title: String) {
        super.init(title: substituteVariables(in: localize(title)))
    }
    
    // -------------------------------------
    required init(coder: NSCoder) {
        super.init(coder: coder)
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
    public override func addItem(_ item: NSMenuItem)
    {
        if item is NSMacMenuItem || !selectorAlreadyAdded(item.action) {
            super.addItem(item)
        }
        else
        {
            #if DEBUG
            print("Refusing to add NSMenuItem named \"\(item.title)\"")
            #endif
        }
    }
    
    // -------------------------------------
    /*
     We don't call this, but macOS's automatically added menus do. We create
     the menu to placate macOS's automatically added menus, but we use the
     standard NSMenuItem instead of our NSMacMenuItem, so we can filter it out
     if we've already implemented the specified selector.
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
        if item is NSMacMenuItem || !selectorAlreadyAdded(item.action) {
            super.insertItem(item, at: index)
        }
        else
        {
            #if DEBUG
            print(
                "Refusing to insert NSMenuItem named \"\(item.title)\" at "
                + "position \(index)"
            )
            #endif
        }
    }
    
    // -------------------------------------
    /*
     We don't call this, but macOS's automatically added menus do. We create
     the menu to placate macOS's automatically added menus, but we use the
     standard NSMenuItem instead of our NSMacMenuItem, so we can filter it out
     if we've already implemented the specified selector.
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
        
        insertItem(item, at: index)
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
//    
//    // -------------------------------------
//    public func menu(
//        _ menu: NSMenu,
//        update item: NSMenuItem,
//        at index: Int,
//        shouldCancel: Bool) -> Bool
//    {
//        return true
//    }
}
