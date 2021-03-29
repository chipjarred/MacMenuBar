//
//  FontSizePopupButton.swift
//  Sudoku
//
//  Created by Chip Jarred on 3/29/21.
//

import SwiftUI

// -------------------------------------
struct FontSizePopupButton<ValueContainer>: PopupButtonProtocol
{
    typealias Value = NSFont
    typealias ValueContainer = ValueContainer
    
    static var fontSize: CGFloat {
        FontFamilyPopupButton<ValueContainer>.fontSize
    }
    
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
        in container: Binding<ValueContainer>,
        content: @escaping () -> [Int])
    {
        let newContent: () -> [NSFont] =
        {
            content().map
            {
                guard let familyName =
                        container.wrappedValue[keyPath: valuePath].familyName
                else { return nil }
                
                return NSFontManager.shared.font(
                    withFamily: familyName,
                    traits: [],
                    weight: 5,
                    size: CGFloat($0)
                )
            }.filter { $0 != nil }.map { $0! }
        }
        
        self.init(
            width: width,
            height: height,
            valuePath: valuePath,
            in: container,
            content: newContent
        )
    }

    // -------------------------------------
    func itemsAreEqual(_ value1: Value, _ value2: Value) -> Bool {
        return value1.pointSize == value2.pointSize
    }
    
    // -------------------------------------
    func attributedItemTitle(from value: Value) -> NSAttributedString?
    {
        return NSAttributedString(
            string: Int(value.pointSize).description,
            attributes:
                [.font : NSFont.systemFont(ofSize: Self.fontSize) as Any]
        )
    }
    
    // -------------------------------------
    func itemTitle(from value: Value) -> String? { nil }
    
    // -------------------------------------
    func value(for itemTitle: String) -> Value?
    {
        guard let familyName = currentValue.familyName,
              let fontSize = Int(itemTitle)
        else { return nil }
        
        return NSFontManager.shared.font(
            withFamily: familyName,
            traits: [],
            weight: 5,
            size: CGFloat(fontSize)
        )
    }
}
