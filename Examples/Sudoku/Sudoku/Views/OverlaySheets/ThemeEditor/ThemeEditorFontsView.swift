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
struct ThemeEditorFontsView: View
{
    @Binding var currentTheme: Theme
    @EnvironmentObject var prefs: Preferences
    
    // -------------------------------------
    var cellPreviewStack: some View
    {
        let cells1 =
        [
            ThemeEditorCellPreview(
                currentTheme: $currentTheme,
                isSelected: false,
                cell: .init(
                    value: 1,
                    guess: nil,
                    fixed: true,
                    notes: []
                )
            ),
            ThemeEditorCellPreview(
                currentTheme: $currentTheme,
                isSelected: false,
                cell: .init(
                    value: 2,
                    guess: 2,
                    fixed: false,
                    notes: []
                )
            ),
            ThemeEditorCellPreview(
                currentTheme: $currentTheme,
                isSelected: false,
                cell: .init(
                    value: 3,
                    guess: nil,
                    fixed: false,
                    notes: [5, 6, 7, 9]
                )
            )
        ]
        let cells2 =
        [
            ThemeEditorCellPreview(
                currentTheme: $currentTheme,
                isSelected: false,
                cell: .init(
                    value: 4,
                    guess: 4,
                    fixed: false,
                    notes: []
                )
            ),
            ThemeEditorCellPreview(
                currentTheme: $currentTheme,
                isSelected: false,
                cell: .init(
                    value: 5,
                    guess: 9,
                    fixed: false,
                    notes: []
                )
            ),
            ThemeEditorCellPreview(
                currentTheme: $currentTheme,
                isSelected: true,
                cell: .init(
                    value: 6,
                    guess: nil,
                    fixed: false,
                    notes: [5, 6, 7, 9]
                )
            )
        ]
        let cells3 =
        [
            ThemeEditorCellPreview(
                currentTheme: $currentTheme,
                isSelected: false,
                cell: .init(
                    value: 7,
                    guess: nil,
                    fixed: false,
                    notes: [3, 7, 9]
                )
            ),
            ThemeEditorCellPreview(
                currentTheme: $currentTheme,
                isSelected: false,
                cell: .init(
                    value: 8,
                    guess: nil,
                    fixed: true,
                    notes: []
                )
            ),
            ThemeEditorCellPreview(
                currentTheme: $currentTheme,
                isSelected: false,
                cell: .init(
                    value: 9,
                    guess: nil,
                    fixed: false,
                    notes: [5, 7, 9]
                )
            )
        ]

        let numCells = CGFloat(cells1.count)
        let numInnerBorders = numCells - 1
        let intercellSpacing: CGFloat = 1
        let outerSpacing: CGFloat = 2
        
        let backgroundWidth = CellView.width * numCells
            + numInnerBorders * intercellSpacing + 2 * outerSpacing
        let backgroundHeight = CellView.height * numCells
            + numInnerBorders * intercellSpacing + 2 * outerSpacing
        
        return ZStack
        {
            Rectangle().fill(Color(currentTheme.borderColor))
                .frame(width: backgroundWidth, height: backgroundHeight)
            
            VStack(alignment: .center, spacing: intercellSpacing)
            {
                HStack(alignment: .top, spacing: intercellSpacing) {
                    ForEach(cells1, id: \.value) { $0 }
                }
                HStack(alignment: .top, spacing: intercellSpacing) {
                    ForEach(cells2, id: \.value) { $0 }
                }
                HStack(alignment: .top, spacing: intercellSpacing) {
                    ForEach(cells3, id: \.value) { $0 }
                }
            }
        }
    }
    
    // -------------------------------------
    var body: some View
    {
        ZStack
        {
            VStack
            {
                cellPreviewStack
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                
                ThemeFontPicker(
                    label: "Value Font",
                    pickerValue: currentTheme.font,
                    size: Int(currentTheme.font.pointSize),
                    currentTheme: $currentTheme,
                    keyPath: \.font
                )
                .padding(.bottom, 10)
                
                ThemeFontPicker(
                    label: "Note Font",
                    pickerValue: currentTheme.noteFont,
                    size: Int(currentTheme.noteFont.pointSize),
                    currentTheme: $currentTheme,
                    keyPath: \.noteFont
                )
            }
            .padding(.top, 10)
        }
    }
}

// -------------------------------------
struct ThemeEditorFontsView_Previews: PreviewProvider {
    static var prefs = Preferences()
    @State static var currentTheme = prefs.theme
    
    // -------------------------------------
    static var previews: some View
    {
        ThemeEditorFontsView(currentTheme: $currentTheme)
            .frame(
                width: PuzzleView.width - ThemeList.width,
                height: PuzzleView.width - ThemeEditor.titleHeight
            ).environmentObject(prefs)
    }
}
