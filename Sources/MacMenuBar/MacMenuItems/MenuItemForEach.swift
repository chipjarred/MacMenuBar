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

import AppKit

fileprivate let dummyMenuItem = NSMacMenuItem()

// -------------------------------------
public struct MenuItemForEach
{
    @usableFromInline
    internal var generator: () -> [NSMenuItem]
    
    // -------------------------------------
    @inlinable
    public init<S: Sequence>(
        of items: S,
        with menuElementMaker: @escaping (S.Element) -> MacMenuItem)
    {
        self.generator =
        { () -> [NSMenuItem] in
            var result = [NSMenuItem]()
            var tempMenu = StandardMenu()

            for item in items
            {
                let menuItem = menuElementMaker(item)
                
                if let macMenuItem = menuItem as? MacMenuItem {
                    result.append(macMenuItem.nsMenuItem)
                }
                else if let macMenu = menuItem as? MacMenu {
                    result.append(macMenu.nsMenu.nsMacMenuItem!)
                }
                else
                {
                    /*
                     This is kind of a silly way to do this, but if menuItem is
                     not a MacMenuItem and not a MacMenu, then it's some other
                     kind of MenuElement (perhaps added in the future).  In
                     that case, it knows how to add itself to a MacMenu, so we
                     add it, then extract it and remove it.  Terribly
                     inefficient, but it works.
                     */
                    menuItem.appendSelf(to: &tempMenu)
                    result.append(tempMenu.nsMenu.items.first!)
                    tempMenu.nsMenu.removeAllItems()
                }
            }
            
            return result
        }
    }
}

// -------------------------------------
extension MenuItemForEach: MenuElement
{
    public var isItem: Bool {
        false
    }
    
    public func appendSelf<T>(to menu: inout T) where T : MacMenu {
        menu.nsMenu.dynamicContent.append(generator)
    }
    
    public var nsMenuItem: NSMenuItem { dummyMenuItem }
    public var isEnabled: Bool { true }

    // -------------------------------------
    public var title: String
    {
        get { "" }
        set { }
    }
    
    // -------------------------------------
    public var isVisible: Bool
    {
        get { true }
        set { }
    }
    
    
    // -------------------------------------
    public var canBeEnabled: Bool
    {
        get { true }
        set { }
    }
}
