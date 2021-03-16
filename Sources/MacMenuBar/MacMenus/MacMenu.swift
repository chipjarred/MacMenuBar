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
