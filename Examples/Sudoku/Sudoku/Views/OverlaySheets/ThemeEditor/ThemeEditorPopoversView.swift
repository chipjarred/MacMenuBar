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
struct ThemeEditorPopoversView: View
{
    @Binding var currentTheme: Theme
    @EnvironmentObject var prefs: Preferences
    
    // -------------------------------------
    func invisibleRect(align: Alignment) -> some View
    {
        Rectangle().fill(Color.black.opacity(0))
            .frame(width: 1, height: 1, alignment: align)
    }
    
    // -------------------------------------
    func spacerRect() -> some View
    {
        Rectangle().fill(Color.black.opacity(0))
            .frame(width: 130, height: 100)
    }
    
    // -------------------------------------
    var noteColorWells: some View
    {
        VStack(alignment: .trailing)
        {
            ThemeColorWell(
                "Available Note",
                currentTheme: $currentTheme,
                colorPath: \.unSelectedNoteColor
            )
            
            ThemeColorWell(
                "Selected Note",
                currentTheme: $currentTheme,
                colorPath: \.selectedNoteColor
            )
        }
        .frame(alignment: .leading)
    }
    
    // -------------------------------------
    var guessColorWells: some View
    {
        VStack(alignment: .trailing)
        {
            ThemeColorWell(
                "Invalid Guess",
                currentTheme: $currentTheme,
                colorPath: \.invalidGuessColor
            )
            
            ThemeColorWell(
                "Valid Guess",
                currentTheme: $currentTheme,
                colorPath: \.validGuessColor
            )
            
            ThemeColorWell(
                "Selected Guess",
                currentTheme: $currentTheme,
                colorPath: \.actualGuessColor
            )
        }
        .frame(alignment: .trailing)
    }
    
    // -------------------------------------
    var notePopoverPreview: some View
    {
        ThemeEditorPopoverPreview(
            currentTheme: $currentTheme,
            settingNotes: true,
            arrowEdge: .leading
        ).frame(ThemeEditorPopoverPreview.size)
    }
    
    // -------------------------------------
    var guessPopoverPreview: some View
    {
        ThemeEditorPopoverPreview(
            currentTheme: $currentTheme,
            settingNotes: false,
            arrowEdge: .trailing
        ).frame(ThemeEditorPopoverPreview.size)
    }
    
    // -------------------------------------
    var body: some View
    {
        VStack
        {
            HStack
            {
                noteColorWells
                notePopoverPreview
            }
            HStack
            {
                guessPopoverPreview
                guessColorWells.padding(.trailing, 5)
            }
        }
    }
}

// -------------------------------------
struct ThemeEditorPopoversView_Previews: PreviewProvider
{
    @State static var theme = Theme.system
    // -------------------------------------
    static var previews: some View
    {
        ZStack
        {
            Color.gray
            ThemeEditorPopoversView(currentTheme: $theme)
        }
        .frame(
            width: PuzzleView.width - ThemeList.width - 10,
            height: PuzzleView.height - 120
        )
    }
}
