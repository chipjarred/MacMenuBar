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
//

import SwiftUI

// -------------------------------------
struct ThemeFontPicker: View
{
    static let sizes = [8, 9, 10, 11, 12, 14, 16, 18, 21, 24, 28, 30, 36, 48]
    var label: String
    @State var pickerValue: NSFont
    @State var size: Int
    @Binding var currentTheme: Theme
    let keyPath: WritableKeyPath<Theme, NSFont>
    
    // -------------------------------------
    var body: some View
    {
        HStack(alignment: .center, spacing: 0)
        {
            Text("\(label):")
                .font(.system(size: 10))
                .frame(alignment: .trailing)
                .padding(.trailing, 5)
            
            FontFamilyPopupButton<Theme>(
                width: 80,
                height: 25,
                valuePath: keyPath,
                in: $currentTheme
            ).frame(alignment: .trailing)
            
            Text("Size:")
                .font(.system(size: 10))
                .frame(alignment: .trailing)
                .padding([.leading, .trailing], 5)

            FontSizePopupButton(
                width: 45,
                height: 25,
                valuePath: keyPath,
                in: $currentTheme,
                content: { Self.sizes }
            )
            .frame(width: 45, height: 25)
        }.frame(width: 200)
    }
}
