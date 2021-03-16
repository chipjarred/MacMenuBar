//
//  NSMenu+Extension.swift
//  
//
//  Created by Chip Jarred on 2/24/21.
//

import Cocoa

// -------------------------------------
public extension NSMenu
{
    // -------------------------------------
    func firstMenuItem(where condition: (NSMenuItem) -> Bool) -> NSMenuItem?
    {
        for item in items
        {
            if let submenu = item.submenu
            {
                if let foundItem = submenu.firstMenuItem(where: condition) {
                    return foundItem
                }
            }
            else if condition(item) { return item }
        }
        
        return nil
    }
    
    // -------------------------------------
    func lastMenuItem(where condition: (NSMenuItem) -> Bool) -> NSMenuItem?
    {
        for item in items.reversed()
        {
            if let submenu = item.submenu
            {
                if let foundItem = submenu.lastMenuItem(where: condition) {
                    return foundItem
                }
            }
            else if condition(item) { return item }
        }
        
        return nil
    }
    
    // -------------------------------------
    internal func selectorAlreadyAdded(_ selector: Selector?) -> Bool
    {
        guard let selector = selector else { return false }
        return nil == rootMenu.firstMenuItem { $0.action == selector }
    }
    
    // -------------------------------------
    internal var rootMenu: NSMenu {
        var curMenu = self
        while curMenu.supermenu != nil {
            curMenu = curMenu.supermenu!
        }
        return curMenu
    }
}
