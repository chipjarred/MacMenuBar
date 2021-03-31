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
import Cocoa

// -------------------------------------
fileprivate extension NSEvent
{
    // -------------------------------------
    var translateRightMouseButtonEvent: NSEvent
    {
        guard let cgEvent = self.cgEvent else { return self }
        
        switch type
        {
            case .rightMouseDown: cgEvent.type = .leftMouseDown
            case .rightMouseUp: cgEvent.type = .leftMouseUp
            case .rightMouseDragged: cgEvent.type = .leftMouseDragged
                
            default: return self
        }
        
        cgEvent.flags.formUnion(.maskControl)
        
        guard let nsEvent = NSEvent(cgEvent: cgEvent) else { return self }
        
        return nsEvent
    }
}

// -------------------------------------
/*
 Translates right-mouse-button events to left-mouse-button events with a
 .control modifier.
 */
class NSGameHostingView: NSHostingView<ContentView>
{
    // -------------------------------------
    @objc public override func rightMouseDown(with event: NSEvent) {
        super.mouseDown(with: event.translateRightMouseButtonEvent)
    }
    
    // -------------------------------------
    @objc public override func rightMouseUp(with event: NSEvent) {
        super.mouseUp(with: event.translateRightMouseButtonEvent)
    }
    
    // -------------------------------------
    @objc public override func rightMouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event.translateRightMouseButtonEvent)
    }

    // -------------------------------------
    @objc public func keyDown(with event: NSEvent) -> Bool {
        return KeyResponder.current?.closure?(event) ?? false
    }
}
