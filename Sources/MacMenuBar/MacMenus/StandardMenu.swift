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
        self.canBeEnabled = true
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
    @inlinable public var canBeEnabled: Bool
    {
        get { nsMenu.nsMacMenuItem?.isEnabled ?? false }
        set { nsMenu.nsMacMenuItem?.canBeEnabled = newValue }
    }
    
    // -------------------------------------
    @inlinable public var isEnabled: Bool {
        nsMenu.nsMacMenuItem?.isEnabled ?? false
    }
}
