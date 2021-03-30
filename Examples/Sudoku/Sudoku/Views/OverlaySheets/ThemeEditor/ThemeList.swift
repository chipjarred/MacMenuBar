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
struct ThemeList: View
{
    static let width: CGFloat = 100
    
    @EnvironmentObject var preferences: Preferences
    @Binding var currentTheme: Theme
    @State var shouldRenameCurrrentTheme: Bool = false
    
    // -------------------------------------
    var scrollView: some View
    {
        ZStack
        {
            Rectangle().fill(Color(.controlBackgroundColor).opacity(0.5))
            ScrollView(.vertical, showsIndicators: true)
            {
                ThemeListCell(
                    .light,
                    currentTheme: $currentTheme,
                    shouldRename: $shouldRenameCurrrentTheme
                )
                ThemeListCell(
                    .dark,
                    currentTheme: $currentTheme,
                    shouldRename: $shouldRenameCurrrentTheme
                )
                
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 1)

                ForEach(preferences.customThemes)
                { aTheme in
                    ThemeListCell(
                        aTheme,
                        currentTheme: $currentTheme,
                        shouldRename: $shouldRenameCurrrentTheme
                    ).environmentObject(preferences)
                }
            }
        }
    }
    
    // -------------------------------------
    var controlButtons: some View
    {
        ZStack
        {
            Rectangle().fill(Color(.controlColor).opacity(0.5))
                .frame(height: 20)
            HStack(spacing: 0)
            {
                ThemeListButton.plus(toolTip: "Add a new theme")
                {
                    let newTheme = Theme(
                        from: currentTheme,
                        withName: currentTheme.name + " Copy"
                    )
                    preferences.addCustomTheme(newTheme)
                    currentTheme = newTheme
                    shouldRenameCurrrentTheme = true
                }.frame(width: 20)
                
                ThemeListButton.minus(
                    toolTip: "Delete the selected theme",
                    isEnabled: ![Theme.light.id, Theme.dark.id]
                        .contains(currentTheme.id)
                ) {
                    preferences.removeCustomTheme(currentTheme)
                    currentTheme = preferences.theme
                }.frame(width:20)
                
                Spacer()
            }
        }
    }
    
    // -------------------------------------
    var body: some View
    {
        HStack(spacing: 0)
        {
            VStack(alignment: .leading, spacing: 0)
            {
                scrollView
                Rectangle().fill(Color.gridColor).frame(height: 1)
                controlButtons
            }
            Rectangle().fill(Color.gridColor).frame(width: 1)
        }
        .frame(width: Self.width)
    }
}
