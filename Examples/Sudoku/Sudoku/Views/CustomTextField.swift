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
struct CustomTextField: NSViewRepresentable
{
    typealias NSViewType = CustomNSTextView
    typealias CommitAction = () -> Void

    @Binding var text: String
    var isFirstResponder: Bool
    var commitAction: CommitAction?
    
    // -------------------------------------
    /*
     The problem CustomTextField is trying to address is that I need a SwiftUI
     TextField-like thing that immediately has focus (ie. is the
     firstResponder, without the user having to do anything more to start
     editing).  SwiftUI's TextField doesn't do that.  You can specify that the
     field is focusable, but not that it has focus, so the  user has to
     explicitly click on it to start editing.  It's possible that SwiftUI 2
     does have a solution for this (as it has for a good many of the problems
     I'm having to solve), but I want to be compatible back to at least
     Catalina, MacOS 10.15.
     
     I've seen iOS solutions for this that use UITextField, and the first
     solution I tried was to translate one of those to use NSTextField...
     bad idea.
     
     The NSTextField solution triggers run-time warnings about re-entrant
     layout constraint updates from NSHostingView.  I tried for days to get
     that solution to work, because apart from that run-time warning, the
     effect was exactly what I want; however, I could never fix the runtime
     warning.  My investingation of it led me to the conclusion that it's
     *probably* because NSTextField uses NSCell and an NSTextView that's
     shared for the entire NSWindow.  Even though my use-case is for a single
     NSTextField at a time, I think what happens is that constraint updates
     happen twice on the same NSTextView in the same rendering pass, once for
     the NSCell being released, and the another for the one being aquired.
     
     The solution, I decided, was to do what NSCell is designed to avoid:
     have a separate NSTextView for each CustomTextField.  I'm not entirely
     happy with this solution, but it cleanly avoids the re-entrant layout
     constraint update problems.  It also simplifies calling the
     commitAction, and is less code than implementing both an NSTextField and
     a Coordinator/delegate.  Setting up a naked NSTextView to behave like an
     NSTextField is a little trickier though.
     */
    @objc class CustomNSTextView: NSTextView
    {
        var isFirstResponder: Bool
        var commitAction: CommitAction
        var savedText: String
        @Binding var text: String
        
        var storage = NSTextStorage()
        
        var alreadyFirstResponder: Bool = false

        // -------------------------------------
        init(text: Binding<String>, isFirstResponder: Bool, onCommit: CommitAction? = nil)
        {
            self._text = text
            self.savedText = text.wrappedValue
            self.isFirstResponder = isFirstResponder
            self.commitAction = onCommit ?? { }
            
            let layoutManager = NSLayoutManager()
            storage.addLayoutManager(layoutManager)
            let container = NSTextContainer(containerSize: .zero)
            layoutManager.addTextContainer(container)
            container.heightTracksTextView = true
            container.widthTracksTextView  = true

            super.init(frame: .zero, textContainer: container)
            
            self.isEditable = true
            self.isSelectable = true
            self.string = text.wrappedValue
            self.textContainerInset = .zero
        }
        
        // -------------------------------------
        deinit
        {
            text = string
            commitAction()
        }
        
        // -------------------------------------
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // -------------------------------------
        override func becomeFirstResponder() -> Bool
        {
            if !alreadyFirstResponder {
                alreadyFirstResponder = super.becomeFirstResponder()
            }
            return alreadyFirstResponder
        }
        
        // -------------------------------------
        override func resignFirstResponder() -> Bool
        {
            if alreadyFirstResponder {
                alreadyFirstResponder = !super.resignFirstResponder()
            }
            return !alreadyFirstResponder
        }
        
        // -------------------------------------
        override var canBecomeKeyView: Bool { true }
        
        // -------------------------------------
        override func viewDidMoveToWindow()
        {
            if isFirstResponder, let w = window
            {
                w.initialFirstResponder = self
                w.makeFirstResponder(self)
            }
        }
        
        // -------------------------------------
        override func insertNewline(_ sender: Any?)
        {
            text = string
            commitAction()
        }
        
        // -------------------------------------
        override func cancelOperation(_ sender: Any?)
        {
            string = savedText
            text = savedText
            commitAction()
        }
    }
    
    // -------------------------------------
    init(
        _ text: Binding<String>,
        isFirstResponder: Bool = false,
        onCommit: (() -> Void)? = nil)
    {
        self._text = text
        self.isFirstResponder = isFirstResponder
        self.commitAction = onCommit
    }

    // -------------------------------------
    func makeNSView(context: Context) -> NSViewType
    {
        return NSViewType(
            text: $text,
            isFirstResponder: isFirstResponder,
            onCommit: commitAction
        )
    }

    // -------------------------------------
    func updateNSView(_ nsView: NSViewType, context: Context)
    {
        nsView.string = text
        nsView.selectAll(nsView)
    }
}
