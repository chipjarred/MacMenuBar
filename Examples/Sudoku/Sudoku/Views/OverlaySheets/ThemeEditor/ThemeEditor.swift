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
struct ThemeEditor: View
{
    static let titleHeight: CGFloat = 35
    @EnvironmentObject var sheetRequest: SheetRequest
    @EnvironmentObject var preferences: Preferences
    
    @State var currentTheme: Theme = Preferences.shared.theme
    
    // -------------------------------------
    func saveThemeChanges()
    {
        preferences.updateTheme(
            currentTheme,
            to: currentTheme
        )
    }
    
    // -------------------------------------
    var tabView: some View
    {
        TabView
        {
            ThemeEditorPuzzleColorsView(
                currentTheme: $currentTheme
            ).environmentObject(preferences)
            .tabItem { Text("Puzzle Colors") }
            
            ThemeEditorFontsView(
                currentTheme: $currentTheme
            ).environmentObject(preferences)
            .tabItem { Text("Fonts") }
            
            ThemeEditorPopoversView(
                currentTheme: $currentTheme
            ).environmentObject(preferences)
                .tabItem { Text("Popovers") }
        }
    }
    
    let helpStr =
    ###"""
    Select a theme to edit in the list to the left.

    To copy a theme:
        • Select it in the list to the left.
        • Click "＋" under the list.
        • Give a new name

    To remove a theme from the list:
        • Select it in the list to the left.
        • Click "－" under the list.

    To rename a theme:
        • Double click it in the list to the left
        • Type the new name

    Note: You cannot edit or rename the "Light" or "Dark" themes, but you can copy them and edit the copies.
    """###
    
    // -------------------------------------
    var themeNotEditable: some View
    {
        return VStack
        {
            Text("Theme \"\(currentTheme.name)\" is not editable")
                .foregroundColor(.controlTextColor)
                .font(.subheadline)
                .padding(.bottom, 10)
            Text(helpStr)
                .frame(alignment: .leading)
                .foregroundColor(.controlTextColor)
                .font(.system(size: 10))
                .padding()
        }
    }
    
    // -------------------------------------
    var body: some View
    {
        KeyResponderGroup
        {
            ZStack
            {
                Color(.controlBackgroundColor).opacity(0.8)
                VStack(spacing: 0)
                {
                    HStack(alignment: .center, spacing: 0) {
                        Text("Edit Theme").font(.title)
                            .foregroundColor(.controlTextColor)
                    }.frame(height: Self.titleHeight)
                    
                    Rectangle()
                        .fill(Color.gridColor)
                        .frame(height: 1)
                    
                    HStack(alignment: .top, spacing: 0)
                    {
                        ThemeList(currentTheme: $currentTheme)
                            .environmentObject(preferences)
                        
                        VStack(alignment: .center, spacing: 0)
                        {
                            if currentTheme.isEditable
                            {
                                tabView.padding(.top, 10)
                                    .padding([.leading, .trailing, .bottom], 5)
                            }
                            else
                            {
                                Spacer()
                                themeNotEditable
                                Spacer()
                            }
                            
                            Rectangle()
                                .fill(Color.gridColor)
                                .frame(height: 1)

                            HStack(alignment: .center)
                            {
                                Spacer()
                                
                                MacOSButton("Done")
                                {
                                    sheetRequest.state = .none
                                    saveThemeChanges()
                                }.frame(width: 100)
                                
                                Spacer()
                                
                                MacOSButton("Set As Current")
                                {
                                    saveThemeChanges()
                                    preferences.theme = currentTheme
                                }.frame(width: 100)
                                
                                Spacer()
                            }.padding([.top, .bottom], 10)
                        }
                    }
                }
            }
        }.transition(
            AnyTransition.opacity.animation(
                .easeInOut(duration: 0.3)
            )
        )

    }
}

// -------------------------------------
struct ThemeEditor_Previews: PreviewProvider
{
    static let prefs: Preferences =
    {
        let p = Preferences()
        p.theme = Theme.dark
        return p
    }()
    static let sheetRequest = SheetRequest()
    
    static var previews: some View {
        ThemeEditor().environmentObject(prefs).environmentObject(sheetRequest)
            .frame(width: PuzzleView.width)
    }
}
