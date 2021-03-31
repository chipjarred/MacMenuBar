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
    @State var shouldRenameCurrentTheme: Bool = false
    @State var needsRefresh: Bool = true
    
    // -------------------------------------
    var scrollView: some View
    {
        ZStack
        {
            Rectangle().fill(Color(.controlBackgroundColor).opacity(0.5))
            ScrollView(.vertical, showsIndicators: true)
            {
                ThemeListCell(
                    .system,
                    currentTheme: $currentTheme,
                    shouldRename: $shouldRenameCurrentTheme,
                    needsRefresh: $needsRefresh
                )
                ThemeListCell(
                    .light,
                    currentTheme: $currentTheme,
                    shouldRename: $shouldRenameCurrentTheme,
                    needsRefresh: $needsRefresh
                )
                ThemeListCell(
                    .dark,
                    currentTheme: $currentTheme,
                    shouldRename: $shouldRenameCurrentTheme,
                    needsRefresh: $needsRefresh
                )
                
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 1)

                if needsRefresh {
                    EmptyView()
                }
                
                ForEach(preferences.customThemes)
                { aTheme in
                    ThemeListCell(
                        aTheme,
                        currentTheme: $currentTheme,
                        shouldRename: $shouldRenameCurrentTheme,
                        needsRefresh: $needsRefresh
                    ).environmentObject(preferences)
                }
            }
        }.onAppear { needsRefresh = !shouldRenameCurrentTheme }
    }
    
    // -------------------------------------
    private func nameWithCopyAppended(_ name: String) -> String
    {
        guard let copyRange = name.lastRange(of: "Copy") else {
            return name + " Copy"
        }
        
        if copyRange.upperBound == name.endIndex {
            return name
        }
        
        guard let numSuffixRange = name.rangeOfNumericSuffix else {
            return name + " Copy"
        }
        
        let betweenRange = copyRange.upperBound..<numSuffixRange.lowerBound
        
        if name[betweenRange].isAllWhitespace {
            return String(name[..<copyRange.upperBound])
        }
        
        return name + " Copy"
    }
    
    // -------------------------------------
    func uniqueName(for theme: Theme) -> String
    {
        let currentThemes = preferences.customThemes + [.light, .dark, .system]
        
        let newName: String = nameWithCopyAppended(theme.name)
        if !currentThemes.contains(where: { $0.name == newName }) {
            return newName
        }

        var i = 1
        while currentThemes.contains(where: { $0.name == "\(newName) \(i)" }) {
            i += 1
        }
        
        return "\(newName) \(i)"
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
                ThemeListButton.plus(toolTip: "Copy selected theme")
                {
                    let newTheme = Theme(
                        from: currentTheme,
                        withName: uniqueName(for: currentTheme)
                    )
                    preferences.addCustomTheme(newTheme)
                    currentTheme = newTheme
                    shouldRenameCurrentTheme = true
                    needsRefresh = true
                }.frame(width: 20)
                
                ThemeListButton.minus(
                    toolTip: "Delete the selected theme",
                    isEnabled: ![Theme.light.id, Theme.dark.id]
                        .contains(currentTheme.id)
                ) {
                    preferences.removeCustomTheme(currentTheme)
                    currentTheme = preferences.theme
                    needsRefresh = true
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
