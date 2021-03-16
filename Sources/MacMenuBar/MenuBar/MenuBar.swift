//
//  MenuBar.swift
//  
//
//  Created by Chip Jarred on 2/20/21.
//

import Cocoa

// -------------------------------------
public protocol MenuBar
{
    var body: StandardMenuBar { get }
}

// -------------------------------------
@_functionBuilder
public struct MenuBarBuilder {
    public static func buildBlock(_ menus: MacMenu...) -> [MacMenu] { menus }
}

// -------------------------------------
public struct StandardMenuBar
{
    public private(set) var menu: StandardMenu
    
    public init(@MenuBarBuilder menus: () -> [MacMenu]){
        self.menu = StandardMenu(items: menus())
    }
}
