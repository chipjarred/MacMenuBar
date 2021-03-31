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
struct ThemeListCell: View
{
    @State var theme: Theme
    @Binding var shouldRename: Bool
    @Binding var currentTheme: Theme
    @State var newName: String = ""
    
    @EnvironmentObject var prefs: Preferences

    // -------------------------------------
    var backColor: Color
    {
        return theme == currentTheme
            ? .accentColor
            : Color(.sRGB, white: 0, opacity: 0)
    }
    
    // -------------------------------------
    init(
        _ theme: Theme,
        currentTheme: Binding<Theme>,
        shouldRename: Binding<Bool>)
    {
        self._theme = State(initialValue: theme)
        self._currentTheme = currentTheme
        self._shouldRename = shouldRename
        self._newName = State(initialValue: theme.name)
    }
    
    // -------------------------------------
    func commitNewThemeName()
    {
        let newTheme = Theme(
            from: currentTheme,
            withName: newName
        )
        prefs.updateTheme(currentTheme, to: newTheme)
        currentTheme = newTheme
        theme = newTheme
        shouldRename = false
    }
    
    // -------------------------------------
    var body: some View
    {
        ZStack(alignment: .leading)
        {
            Rectangle().fill(backColor)
            if shouldRename && theme == currentTheme
            {
                CustomTextField(
                    $newName,
                    isFirstResponder: true,
                    onCommit: { commitNewThemeName() }
                )
                .frame(height: 15)
                .padding(.leading, 5)
                .background(Color.controlBackgroundColor)
                .border(Color.blue, width: 1)
            }
            else
            {
                Text(theme.name)
                    .foregroundColor(.controlTextColor)
                    .padding(.leading, 10)
                    .onTapGesture(count: 2) {
                        shouldRename = theme.isEditable
                    }
                    .onTapGesture(count: 1)
                    {
                        if theme == currentTheme {
                            shouldRename = theme.isEditable
                        }
                        else
                        {
                            currentTheme = theme
                            shouldRename = false
                        }
                    }
            }
        }
    }
}
