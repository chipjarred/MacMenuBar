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
import SwiftUI

// -------------------------------------
fileprivate func _setMenuBar<MenuBarType: MenuBar>(to menuBar: MenuBarType)
{
    DispatchQueue.main.async
    {
        let menu = menuBar.body.menu
        // Build dynamic menu content before setting the menu bar so our menus
        // are populated before macOS knows about them to inject its own.
        for item in menu.items
        {
            if let submenu = item.submenu {
                let _ = submenu.delegate?.numberOfItems?(in: submenu)
            }
        }
        NSApplication.shared.mainMenu = menu
    }
}

// -------------------------------------
public extension SwiftUI.App
{
    // -------------------------------------
    func setMenuBar<MenuBarType: MenuBar>(to menuBar: MenuBarType) {
        _setMenuBar(to: menuBar)
    }
}

// -------------------------------------
public extension NSApplicationDelegate
{
    func setMenuBar<MenuBarType: MenuBar>(to menuBar: MenuBarType) {
        _setMenuBar(to: menuBar)
    }
}
