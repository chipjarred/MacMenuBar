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

import SwiftUI

fileprivate let _fontSize: CGFloat = 11

// -------------------------------------
fileprivate func font(from family: String) -> NSFont?
{
    NSFontManager.shared.font(
        withFamily: family,
        traits: [], weight: 5,
        size: _fontSize
    )
}

// -------------------------------------
fileprivate let fontList = NSFontManager.shared.availableFontFamilies
    .map { font(from: $0) }.filter { $0 != nil }.map { $0! }

// -------------------------------------
fileprivate var attributedFontNames: [String: NSAttributedString] =
{
    var map = [String: NSAttributedString]()
    map.reserveCapacity(fontList.count)
    
    for font in fontList
    {
        guard let familyName = font.familyName else { continue }
        map[familyName] = familyName.attributedString(font)
    }
    return map
}()

// -------------------------------------
struct FontFamilyPopupButton<ValueContainer>: PopupButtonProtocol
{
    typealias Value = NSFont
    typealias ValueContainer = ValueContainer
    
    static var fontSize: CGFloat { _fontSize }
    
    var width: CGFloat
    var height: CGFloat
    var valueContainer: Binding<ValueContainer>
    var valuePath: ValuePath
    var content: () -> [NSFont]
    
    // -------------------------------------
    init(
        width: CGFloat,
        height: CGFloat,
        valuePath: ValuePath,
        in container: Binding<ValueContainer>,
        content: @escaping () -> [NSFont])
    {
        self.width = width
        self.height = height
        self.valueContainer = container
        self.valuePath = valuePath
        self.content = content
    }
    
    // -------------------------------------
    init(
        width: CGFloat,
        height: CGFloat,
        valuePath: ValuePath,
        in container: Binding<ValueContainer>)
    {
        self.init(
            width: width,
            height: height,
            valuePath: valuePath,
            in: container) { fontList }
    }

    // -------------------------------------
    func itemsAreEqual(_ value1: Value, _ value2: Value) -> Bool {
        return value1.familyName == value2.familyName
    }
    
    // -------------------------------------
    func attributedItemTitle(from value: Value) -> NSAttributedString?
    {
        guard let familyName = value.familyName else { return nil }
        if let attributedName = attributedFontNames[familyName] {
            return attributedName
        }
        
        let attributedName = familyName.attributedString(value)
        attributedFontNames[familyName] = attributedName
        return attributedName
    }
    
    // -------------------------------------
    func itemTitle(from value: Value) -> String? { nil }
    
    // -------------------------------------
    func value(for itemTitle: String) -> Value?
    {
        return NSFontManager.shared.font(
            withFamily: itemTitle,
            traits: [],
            weight: 5,
            size: currentValue.pointSize
        )
    }
}
