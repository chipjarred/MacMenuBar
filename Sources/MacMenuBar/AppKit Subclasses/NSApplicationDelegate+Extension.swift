//
//  NSApplicationDelegate.swift
//  
//
//  Created by Chip Jarred on 2/20/21.
//

import Cocoa

// -------------------------------------
public extension NSApplicationDelegate
{
    func setMenuBar<MenuBarType: MenuBar>(to menuBar: MenuBarType) {
        NSApplication.shared.mainMenu = menuBar.body.menu.nsMenu
    }
}
