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

fileprivate let fontList = NSFontManager.shared.availableFontFamilies
fileprivate let fontSize: CGFloat = 11

// -------------------------------------
/*
 MacMenuBar doesn't currently allow setting attributed titles, and since we
 want a font menu to show fonts in their own face, we use standard NSMenu and
 NSMenuItem to build the font menu.
 */
struct FontPopupButton<StylableThing>: NSViewRepresentable
{
    typealias NSViewType = CustomNSPopUpButton
    typealias FontPath = WritableKeyPath<StylableThing, NSFont>
    
    let width: CGFloat
    let height: CGFloat
    
    @Binding var stylableThing: StylableThing
    let fontPath: FontPath
    
    // -------------------------------------
    var font: NSFont
    {
        get { stylableThing[keyPath: fontPath] }
        set { stylableThing[keyPath: fontPath] = newValue }
    }
    
    // -------------------------------------
    class CustomNSPopUpButton: NSPopUpButton
    {
        let width: CGFloat
        let height: CGFloat
        var size: CGSize { CGSize(width: width, height: height) }
        @Binding var thing: StylableThing
        let fontPath: FontPath
        
        // -------------------------------------
        override var intrinsicContentSize: NSSize
        {
            return NSSize(
                width: width,
                height: height
            )
        }
        
        // -------------------------------------
        init(
            frame buttonFrame: NSRect,
            pullsDown flag: Bool,
            stylableThing: Binding<StylableThing>,
            fontPath: FontPath)
        {
            self.width = buttonFrame.width
            self.height = buttonFrame.height
            self._thing = stylableThing
            self.fontPath = fontPath
            
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
        public override func setFrameSize(_ newSize: NSSize) {
            super.setFrameSize(size)
        }
        
        // -------------------------------------
        @objc public func itemSelected(_ sender: Any?)
        {
            guard let item = selectedItem else { return }
            
            let fontFamilyName = item.attributedTitle!.string
            guard let font = NSFontManager.shared.font(
                withFamily: fontFamilyName,
                traits: [],
                weight: 5,
                size: thing[keyPath: fontPath].pointSize)
            else { return }
            
            thing[keyPath: fontPath] = font
        }
    }
    
    // -------------------------------------
    func makeNSView(context: Context) -> NSViewType
    {
        let button = NSViewType(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: width, height: height)
            ),
            pullsDown: false,
            stylableThing: $stylableThing,
            fontPath: fontPath
        )
        
        button.autoenablesItems = false
        
        var selectedItemIndex = 0
        
        for fontName in fontList
        {
            let font = NSFontManager.shared.font(
                withFamily: fontName,
                traits: [],
                weight: 5,
                size: fontSize
            ) ?? NSFont.systemFont(ofSize: fontSize)
            
            let item = NSMenuItem()
            item.attributedTitle = NSAttributedString(
                string: fontName,
                attributes: [.font : font as Any]
            )
            item.action = #selector(NSViewType.itemSelected(_:))
            item.target = button
            
            if fontName == self.font.familyName
            {
                selectedItemIndex = button.menu!.items.count
                item.state = .on
            }

            button.menu!.addItem(item)
        }
        
        button.selectItem(at: selectedItemIndex)
        
        return button
    }
    
    // -------------------------------------
    func updateNSView(_ nsView: NSViewType, context: Context) { }
    
}

