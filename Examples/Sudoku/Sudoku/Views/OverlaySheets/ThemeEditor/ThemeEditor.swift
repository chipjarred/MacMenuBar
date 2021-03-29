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
    var body: some View
    {
        KeyResponderGroup
        {
            ZStack
            {
                Color.black.opacity(0.8)
                VStack(spacing: 0)
                {
                    HStack(alignment: .center, spacing: 0) {
                        Text("Edit Theme").font(.title)
                    }.frame(height: Self.titleHeight)
                    
                    Rectangle()
                        .fill(Color.controlColor)
                        .frame(height: 1)
                    
                    HStack(alignment: .top, spacing: 0)
                    {
                        ThemeList(currentTheme: $currentTheme)
                            .environmentObject(preferences)
                        
                        VStack(alignment: .center, spacing: 0)
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
                                
                                Rectangle().fill(Color.black.opacity(0))
                                    .tabItem { Text("Popovers") }
                            }

                            HStack(alignment: .center)
                            {
                                Spacer()
                                
                                MacOSButton("Cancel") {
                                    sheetRequest.state = .none
                                }.frame(width: 100)
                                
                                Spacer()
                                
                                MacOSButton("Done")
                                {
                                    sheetRequest.state = .none
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
