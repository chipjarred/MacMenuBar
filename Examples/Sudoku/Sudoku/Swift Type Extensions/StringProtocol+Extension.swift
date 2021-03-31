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

import AppKit

// -------------------------------------
extension StringProtocol
{
    // -------------------------------------
    func attributedString(_ font: NSFont) -> NSAttributedString {
        attributedString([.font: font])
    }
    
    // -------------------------------------
    func attributedString(
        _ attributes: [NSAttributedString.Key: Any]) -> NSAttributedString
    {
        NSAttributedString(string: String(self), attributes: attributes)
    }
    
    // -------------------------------------
    func lastRange<S: StringProtocol>(of substr: S) -> Range<Index>?
    {
        var s = self[...]
        var foundRange: Range<Index>? = nil
        while let r = s.range(of: substr)
        {
            foundRange = r
            s = s[r.upperBound...]
        }
        
        return foundRange
    }
    
    // -------------------------------------
    var rangeOfNumericSuffix: Range<Self.Index>?
    {
        guard count > 0 && last!.isNumber else { return nil }
        
        guard let lastNonDigitIndex = lastIndex(where: { !$0.isNumber }) else {
            return startIndex..<endIndex
        }
        
        return index(after: lastNonDigitIndex)..<endIndex
    }
    
    // -------------------------------------
    var isAllWhitespace: Bool { firstIndex { !$0.isWhitespace } == nil }
}
