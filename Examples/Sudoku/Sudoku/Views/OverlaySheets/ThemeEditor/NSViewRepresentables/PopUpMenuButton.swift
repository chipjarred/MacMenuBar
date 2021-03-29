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

// -------------------------------------
protocol PopupButtonProtocol: NSViewRepresentable
    where NSViewType == CustomNSPopUpButton
{
    associatedtype ValueContainer
    associatedtype Value
    
    typealias ValuePath = WritableKeyPath<ValueContainer, Value>

    var width : CGFloat { get }
    var height: CGFloat { get }
    
    var valueContainer: Binding<ValueContainer> { get }
    var valuePath: ValuePath { get }
    var content: () -> [Value] { get }
    
    init(
        width: CGFloat,
        height: CGFloat,
        valuePath: ValuePath,
        in container: Binding<ValueContainer>,
        content: @escaping () -> [Value])
    
    func itemsAreEqual(_ value1: Value, _ value2: Value) -> Bool
    func attributedItemTitle(from value: Value) -> NSAttributedString?
    func itemTitle(from value: Value) -> String?
    func value(for itemTitle: String) -> Value?
}

// -------------------------------------
extension PopupButtonProtocol
{
    // -------------------------------------
    var currentValue: Value
    {
        get { valueContainer.wrappedValue[keyPath: valuePath] }
        set { valueContainer.wrappedValue[keyPath: valuePath] = newValue }
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
            guard let itemTitle = item.attributedTitle?.string ?? item.title,
                  let value = value(for: itemTitle)
            else { return }
            
            valueContainer.wrappedValue[keyPath: valuePath] = value
        }
        
        populate(button: button, from: content())
        
        return button
    }
    
    // -------------------------------------
    func updateNSView(_ nsView: NSViewType, context: Context) { }

    /*
     MacMenuBar doesn't currently allow setting attributed titles, and since we
     want a menu items to optionally have attritbuted titles, we use standard
     NSMenu and NSMenuItem to build the font menu.
     */
    
    // -------------------------------------
    private func makeItem(from value: Value) -> NSMenuItem?
    {
        if let styledTitle = attributedItemTitle(from: value)
        {
            let item = NSMenuItem()
            item.attributedTitle = styledTitle
            return item
        }
        
        if let plainTitle = itemTitle(from: value)
        {
            let item = NSMenuItem()
            item.title = plainTitle
            return item
        }
        
        return nil
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
}

// -------------------------------------
extension PopupButtonProtocol
{
    // -------------------------------------
    func attributedItemTitle(from value: Value) -> NSAttributedString? { nil }
}

// -------------------------------------
extension PopupButtonProtocol where Value: Equatable
{
    // -------------------------------------
    func itemsAreEqual(_ value1: Value, _ value2: Value) -> Bool {
        return value1 == value2
    }
}

// -------------------------------------
extension PopupButtonProtocol where Value: Identifiable
{
    // -------------------------------------
    func itemsAreEqual(_ value1: Value, _ value2: Value) -> Bool {
        return value1.id == value2.id
    }
}

// -------------------------------------
extension PopupButtonProtocol where Value: CustomStringConvertible
{
    // -------------------------------------
    func itemTitle(from value: Value) -> String? { value.description }
}

// -------------------------------------
extension PopupButtonProtocol where Value: FixedWidthInteger
{
    // -------------------------------------
    func value(for itemTitle: String) -> Value? { Value(itemTitle) }
}

// -------------------------------------
extension PopupButtonProtocol where Value == String
{
    // -------------------------------------
    func value(for itemTitle: String) -> Value? { itemTitle }
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
