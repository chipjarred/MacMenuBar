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
extension Color
{
    static var controlColor: Color { Color(.controlColor) }
    static var controlBackgroundColor: Color { Color(.controlBackgroundColor) }
    static var controlAccentColor: Color { Color(.controlAccentColor) }
    static var controlTextColor: Color { Color(.controlTextColor) }
    static var selectedControlTextColor: Color {
        Color(.selectedControlTextColor)
    }
    static var disabledControlTextColor: Color {
        Color(.disabledControlTextColor)
    }
    static var controlShadowColor: Color { Color(.controlShadowColor) }
    static var controlHighlightColor: Color { Color(.controlHighlightColor) }
    static var controlDarkShadowColor: Color { Color(.controlDarkShadowColor) }
    static var controlLightHighlightColor: Color {
        Color(.controlLightHighlightColor)
    }
    static var selectedControlColor: Color { Color(.selectedControlColor) }
    static var secondarySelectedControlColor: Color {
        Color(.secondarySelectedControlColor)
    }
    static var alternateSelectedControlColor: Color {
        Color(.alternateSelectedControlColor)
    }
    static var alternateSelectedControlTextColor: Color {
        Color(.alternateSelectedControlTextColor)
    }
    
    static var windowFrameColor: Color { Color(.windowFrameColor) }
    static var windowBackgroundColor: Color { Color(.windowBackgroundColor) }
    static var windowFrameTextColor: Color { Color(.windowFrameTextColor) }
    
    static var gridColor: Color { Color(.gridColor) }
}
