//
//  StandardMenu.swift
//  
//
//  Created by Chip Jarred on 2/20/21.
//

// -------------------------------------
public struct StandardMenu
{
    public internal(set) var nsMenu: NSMacMenu
    
    // -------------------------------------
    public init(menu: StandardMenu?) {
        self.init(menu?.nsMenu ?? NSMacMenu())
    }
    
    // -------------------------------------
    public init(title: String) {
        self.init(NSMacMenu(title: title))
    }
    
    // -------------------------------------
    public init(title: String, @MenuBuilder items: () -> [MenuElement])
    {
        self.init(items: items)
        self.nsMenu.title = title
        self.isVisible = true
        self.isEnabled = true
    }

    // -------------------------------------
    public init(_ nsMenu: NSMacMenu)  {
        self.nsMenu = nsMenu
        nsMenu.delegate = nsMenu
    }
}

// -------------------------------------
extension StandardMenu: MacMenu
{
    public init() {
        self.init(menu: nil)
    }
    
    // -------------------------------------
    @inlinable public var isItem: Bool { false }

    // -------------------------------------
    @inlinable public var title: String
    {
        get { nsMenu.title }
        set { nsMenu.title = newValue }
    }
    
    // -------------------------------------
    @inlinable public var isVisible: Bool
    {
        get { !(nsMenu.nsMacMenuItem?.isHidden ?? true) }
        set { nsMenu.nsMacMenuItem?.isHidden = !newValue }
    }
    
    // -------------------------------------
    @inlinable public var isEnabled: Bool
    {
        get { nsMenu.nsMacMenuItem?.isEnabled ?? false }
        set { nsMenu.nsMacMenuItem?.isEnabled = !newValue }
    }
}
