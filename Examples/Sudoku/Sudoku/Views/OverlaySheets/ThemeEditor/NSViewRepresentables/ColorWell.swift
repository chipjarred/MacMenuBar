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
struct ColorWell<ColoredThing>: NSViewRepresentable
{
    typealias NSViewType = CustomNSColorWell
    typealias NSColorPath = WritableKeyPath<ColoredThing, NSColor>
    
    @Binding var coloredThing: ColoredThing
    var colorPath: NSColorPath
    
    // -------------------------------------
    init(
        _ coloredThing: Binding<ColoredThing>,
        colorPath: NSColorPath)
    {
        self._coloredThing = coloredThing
        self.colorPath = colorPath
    }
    
    // -------------------------------------
    class CustomNSColorWell: NSColorWell
    {
        @Binding var coloredThing: ColoredThing
        var colorPath: NSColorPath
        var canInterceptUpdates = false
        
        // -------------------------------------
        init(
            _ coloredThing: Binding<ColoredThing>,
            colorPath: NSColorPath)
        {
            self._coloredThing = coloredThing
            self.colorPath = colorPath
            super.init(frame: .zero)
            super.color = coloredThing.wrappedValue[keyPath: colorPath]
            self.canInterceptUpdates = true
        }
        
        // -------------------------------------
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // -------------------------------------
        override var color: NSColor
        {
            didSet
            {
                if canInterceptUpdates {
                    self.coloredThing[keyPath: colorPath] = super.color
                }
            }
        }
    }
    
    // -------------------------------------
    func makeNSView(context: Context) -> NSViewType {
        return CustomNSColorWell($coloredThing, colorPath: colorPath)
    }
    
    // -------------------------------------
    func updateNSView(_ nsView: NSViewType, context: Context)
    {
        DispatchQueue.main.async {
            nsView.color = coloredThing[keyPath: colorPath]
        }
    }
}
