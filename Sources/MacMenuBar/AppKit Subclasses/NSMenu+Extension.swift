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
        guard let selector = selector,
              let item = rootMenu.firstMenuItem(where:{ $0.action == selector })
        else { return false }
        return true
//        return nil == rootMenu.firstMenuItem { $0.action == selector }
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
