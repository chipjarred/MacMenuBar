//
//  MacMenu.swift
//  
//
//  Created by Chip Jarred on 2/20/21.
//

import Cocoa

// -------------------------------------
public protocol MacMenu: MenuElement
{
    var nsMenu: NSMacMenu { get }
    
    mutating func append<T: MacMenuItem>(item: T)
    mutating func append<T: MacMenu>(submenu: T)
    
    init()
}

// -------------------------------------
extension MacMenu
{
    // -------------------------------------
    init(@MenuBuilder items: () -> [MenuElement])
    {
        self.init()
        items().forEach {
            $0.appendSelf(to: &self)
        }
    }
    
    // -------------------------------------
    init(items: [MacMenu])
    {
        self.init()
        items.forEach {
            $0.appendSelf(to: &self)
        }
   }
    
    // -------------------------------------
    @inlinable
    public func appendSelf<T: MacMenu>(to menu: inout T) {
        menu.append(submenu: self)
    }

    // -------------------------------------
    @inlinable
    public mutating func append<T: MacMenuItem>(item: T) {
        nsMenu.addItem(item.nsMenuItem)
    }
    
    // -------------------------------------
    @inlinable
    public mutating func append<T: MacMenu>(submenu: T)
    {
        let nsMenu = self.nsMenu
        
        if let group = submenu as? MenuItemGroup
        {
            if let lastItem = nsMenu.items.last, !lastItem.isSeparatorItem {
                nsMenu.addItem(NSMenuItem.separator())
            }
            
            for item in group.nsMenu.items {
                nsMenu.addItem(item)
            }
        }
        else {
            nsMenu.addSubmenu(submenu.nsMenu)
        }
    }
}
