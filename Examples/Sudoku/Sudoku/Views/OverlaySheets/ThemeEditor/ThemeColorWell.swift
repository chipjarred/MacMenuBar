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
struct ThemeColorWell: View
{
    let label: String
    @Binding var currentTheme: Theme
    let colorPath: WritableKeyPath<Theme, NSColor>
    
    init(
        _ label: String,
        currentTheme: Binding<Theme>,
        colorPath: WritableKeyPath<Theme, NSColor>)
    {
        self.label = label
        self._currentTheme = currentTheme
        self.colorPath = colorPath
    }
        
    // -------------------------------------
    public var body: some View
    {
        HStack(spacing: 0)
        {
            Text("\(label):")
                .font(.system(size: 10))
                .frame(alignment: .trailing)
                .padding([.leading, .trailing], 5)
            ColorWell($currentTheme, colorPath: colorPath)
                .frame(width: 50, height: 20, alignment: .leading)
        }
    }
}

// -------------------------------------
struct ThemeColorWell_Previews: PreviewProvider
{
    static let prefs = Preferences()
    @State static var currentTheme = prefs.theme
    
    // -------------------------------------
    static var previews: some View {
        ThemeColorWell("Some Color", currentTheme: $currentTheme, colorPath: \.validGuessColor)
    }
}
