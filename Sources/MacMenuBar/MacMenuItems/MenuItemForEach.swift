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
public struct MenuItemForEach<Source: Sequence>
{
    @usableFromInline
    internal var generator: () -> [MenuElement]
    
    // -------------------------------------
    @inlinable
    public init(
        _ items: Source,
        with menuElementMaker: @escaping (Source.Element) -> MenuElement)
    {
        self.generator =
        { () -> [MenuElement] in
            var result = [MenuElement]()
            
            for item in items {
                result.append(menuElementMaker(item))
            }
            
            return result
        }
    }
}

// -------------------------------------
extension MenuItemForEach: MacMenuItem
{
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
