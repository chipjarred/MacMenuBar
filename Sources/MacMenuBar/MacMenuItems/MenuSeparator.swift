//
//  MacMenuSeparator.swift
//  
//
//  Created by Chip Jarred on 2/20/21.
//

import Cocoa

// -------------------------------------
public struct MenuSeparator
{
    public private(set) var nsMenuItem: NSMenuItem = NSMacMenuItem.separator()
    
    public init() { }
}

// -------------------------------------
extension MenuSeparator: MacMenuItem
{
    // -------------------------------------
    public var title: String
    {
        get { nsMenuItem.title }
        set { }
    }
    
    // -------------------------------------
    public var isVisible: Bool
    {
        get { true }
        set { }
    }
    
    // -------------------------------------
    public var isEnabled: Bool
    {
        get { false }
        set { }
    }
}
