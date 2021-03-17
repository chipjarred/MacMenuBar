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
//

import AppKit

// -------------------------------------
struct DynamicNSMenuContent
{
    // -------------------------------------
    struct Group
    {
        let generator: () -> [NSMenuItem]
        
        // -------------------------------------
        init(with generator: @escaping () -> [NSMenuItem]) {
            self.generator = generator
        }
        
        // -------------------------------------
        func addAll(to menu: NSMacMenu) {
            generator().forEach { menu.addItem($0) }
        }
    }
    
    var groups: [Group] = []
    
    // -------------------------------------
    mutating func append(_ item: NSMenuItem) {
        groups.append(Group { [item] })
    }
    
    // -------------------------------------
    mutating func append(_ submenu: NSMenu)
    {
        groups.append(
            Group
            {
                if let item = submenu.parentItem { return [item] }
                return []
            }
        )
    }
    
    // -------------------------------------
    mutating func append(_ elements: @escaping () -> [NSMenuItem]) {
        groups.append(Group(with: elements))
    }
    
    // -------------------------------------
    func rebuild(for menu: NSMacMenu)
    {
        menu.rebuilding = true
        defer { menu.rebuilding = false }
        
        /*
         Annoyingly, macOS inserts its own menu items into our menus.  We
         already refuse the insert the ones that use selectors we already
         implement menu items for, so we don't get duplicates,  but we allow it
         for ones we don't so that users get the menus they expect for their
         macOS version.
         
         The problem is that injected menus aren't in our groups, so we have to
         save any menu items that aren't NSMacMenuItems and then append them to
         the end afterwards.
         
         Currently, macOS always inserts those at the end of the menu.  If some
         future macOS version inserts them elsewhere... well they're about to be
         re-arranged.
         */
        let savedItems = menu.items.filter { !($0 is NSMacMenuItem) }
        
        menu.removeAllItems()
        groups.forEach { $0.addAll(to: menu) }
        
        savedItems.forEach { menu.addItem($0) }
    }
}

// -------------------------------------
fileprivate extension NSMenu
{
    // -------------------------------------
    var parentItem: NSMenuItem?
    {
        guard let index = supermenu?.indexOfItem(withSubmenu: self) else {
            return nil
        }
        
        return supermenu?.items[index]
    }
}
