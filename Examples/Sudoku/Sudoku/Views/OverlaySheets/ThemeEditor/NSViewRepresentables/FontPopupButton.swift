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

fileprivate let fontSize: CGFloat = 11

// -------------------------------------
fileprivate func font(from family: String) -> NSFont?
{
    NSFontManager.shared.font(
        withFamily: family,
        traits: [], weight: 5,
        size: fontSize
    )
}

fileprivate let fontList = NSFontManager.shared.availableFontFamilies
    .map { font(from: $0) }.filter { $0 != nil }.map { $0! }

// -------------------------------------
/*
 MacMenuBar doesn't currently allow setting attributed titles, and since we
 want a font menu to show fonts in their own face, we use standard NSMenu and
 NSMenuItem to build the font menu.
 */
struct FontPopupButton<ValueContainer>: NSViewRepresentable
{
    typealias Value = NSFont
    typealias NSViewType = CustomNSPopUpButton
    typealias ValuePath = WritableKeyPath<ValueContainer, Value>
    
    let width: CGFloat
    let height: CGFloat
    
    @Binding var stylableThing: ValueContainer
    let valuePath: ValuePath
    
    // -------------------------------------
    var currentValue: NSFont
    {
        get { stylableThing[keyPath: valuePath] }
        set { stylableThing[keyPath: valuePath] = newValue }
    }
    
    // -------------------------------------
    class CustomNSPopUpButton: NSPopUpButton
    {
        typealias ItemSelectionAction = (NSMenuItem) -> Void
        let width: CGFloat
        let height: CGFloat
        var size: CGSize { CGSize(width: width, height: height) }
        let itemSelectionAction: ItemSelectionAction
        
        // -------------------------------------
        override var intrinsicContentSize: NSSize {
            return NSSize(width: width, height: height)
        }
        
        // -------------------------------------
        init(
            frame buttonFrame: NSRect,
            pullsDown flag: Bool,
            onSelection: @escaping ItemSelectionAction)
        {
            self.width = buttonFrame.width
            self.height = buttonFrame.height
            self.itemSelectionAction = onSelection
            
            super.init(frame: buttonFrame, pullsDown: flag)
        }

        // -------------------------------------
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // -------------------------------------
        public override func viewDidMoveToSuperview()
        {
            super.viewDidMoveToSuperview()
            setFrameSize(size)
        }
        
        // -------------------------------------
        @objc public func itemSelected(_ sender: Any?)
        {
            guard let item = selectedItem else { return }
            itemSelectionAction(item)
        }
    }
    
    // -------------------------------------
    public func itemsAreEqual(_ value1: Value, _ value2: Value) -> Bool {
        return value1.familyName == value2.familyName
    }
    
    // -------------------------------------
    private func makeItem(from value: Value) -> NSMenuItem?
    {
        guard let familyName = value.familyName else { return nil }
        let item = NSMenuItem()
        item.attributedTitle = NSAttributedString(
            string: familyName,
            attributes: [.font : value as Any]
        )
        return item
    }
    
    // -------------------------------------
    private func populate(button: NSViewType, from values: [Value])
    {
        button.autoenablesItems = false
        
        var selectedItemIndex = 0
        
        for value in values
        {
            guard let item = makeItem(from: value) else { continue }

            item.action = #selector(NSViewType.itemSelected(_:))
            item.target = button
            
            if itemsAreEqual(value, currentValue)
            {
                selectedItemIndex = button.menu!.items.count
                item.state = .on
            }

            button.menu!.addItem(item)
        }
        
        button.selectItem(at: selectedItemIndex)
    }
    
    // -------------------------------------
    func makeNSView(context: Context) -> NSViewType
    {
        let buttonRect = CGRect(
            origin: .zero,
            size: CGSize(width: width, height: height)
        )
        let button = NSViewType(frame: buttonRect, pullsDown: false)
        { item in
            let fontFamilyName = item.attributedTitle!.string
            guard let font = NSFontManager.shared.font(
                withFamily: fontFamilyName,
                traits: [],
                weight: 5,
                size: currentValue.pointSize)
            else { return }
            
            stylableThing[keyPath: valuePath] = font
        }
        
        populate(button: button, from: fontList)
        
        return button
    }
    
    // -------------------------------------
    func updateNSView(_ nsView: NSViewType, context: Context) { }
    
}

