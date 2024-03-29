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
fileprivate struct MenuItemCache
{
    // -------------------------------------
    struct Key: Hashable
    {
        let typeHash: Int
        let title: String
        
        // -------------------------------------
        init<Value>(valueType: Value.Type, title: String)
        {
            self.typeHash = "\(valueType)".hashValue
            self.title = title
        }
    }
    
    var items = [Key: [NSMenuItem]]()
    
    // -------------------------------------
    mutating func getItem<Value>(
        for valueType: Value.Type,
        title: String) -> NSMenuItem?
    {
        let key = Key(valueType: valueType, title: title)
        if let item = items[key]?.popLast()
        {
            item.state = .off
            item.isEnabled = true
            item.isHidden = false
            return item
        }
        return nil
    }
    
    // -------------------------------------
    mutating func putItem<Value>(
        _ item: NSMenuItem,
        for valueType: Value.Type)
    {
        assert(item.title.count > 0)
        let key = Key(valueType: valueType, title: item.title)
        
        if items.keys.contains(key) {
            items[key]!.append(item)
        }
        else { items[key] = [item] }
    }
}

fileprivate var menuItemCache = MenuItemCache()


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
            let itemTitle = item.attributedTitle?.string ?? item.title
            guard let value = value(for: itemTitle) else { return }
            
            valueContainer.wrappedValue[keyPath: valuePath] = value
        }
        onDeinit: { if let items = $0 { cacheMenuItems(items: items) } }
        
        populate(button: button, from: content())
        
        return button
    }
    
    // -------------------------------------
    func updateNSView(_ nsView: NSViewType, context: Context)
    {
        let cValue = currentValue
        guard let currentTitle = attributedItemTitle(from: cValue)?.string
                ?? itemTitle(from: cValue),
              let item = nsView.menu?.items.first(
                where: { $0.title == currentTitle })
        else { return }
        
        nsView.select(item)
    }

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
            if let cachedItem = menuItemCache.getItem(
                for: Value.self, title: styledTitle.string)
            {
                return cachedItem
            }
            
            let item = NSMenuItem()
            item.attributedTitle = styledTitle
            return item
        }
        
        if let plainTitle = itemTitle(from: value)
        {
            if let cachedItem =
                menuItemCache.getItem(for: Value.self, title: plainTitle)
            {
                return cachedItem
            }
            
            let item = NSMenuItem()
            item.title = plainTitle
            return item
        }
        
        return nil
    }
    
    // -------------------------------------
    private func cacheMenuItems(items: [NSMenuItem]) {
        items.forEach { menuItemCache.putItem($0, for: Value.self) }
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
    typealias DeinitAction = ([NSMenuItem]?) -> Void
    
    let width: CGFloat
    let height: CGFloat
    var size: CGSize { CGSize(width: width, height: height) }
    let itemSelectionAction: ItemSelectionAction
    let deinitAction: DeinitAction
    
    // -------------------------------------
    override var intrinsicContentSize: NSSize {
        return NSSize(width: width, height: height)
    }
    
    // -------------------------------------
    init(
        frame buttonFrame: NSRect,
        pullsDown flag: Bool,
        onSelection: @escaping ItemSelectionAction,
        onDeinit: @escaping DeinitAction)
    {
        self.width = buttonFrame.width
        self.height = buttonFrame.height
        self.itemSelectionAction = onSelection
        self.deinitAction = onDeinit
        
        super.init(frame: buttonFrame, pullsDown: flag)
    }

    // -------------------------------------
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // -------------------------------------
    deinit { deinitAction(menu?.items) }
    
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
