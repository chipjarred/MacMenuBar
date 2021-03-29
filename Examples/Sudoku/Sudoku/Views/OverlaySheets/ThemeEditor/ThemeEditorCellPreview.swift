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
struct ThemeEditorCellPreview: View
{
    static let width = CellView.width
    static let height = CellView.height
    static let frame = CellView.frame
    static let gradient = CellView.gradient
    
    typealias HighlightPath = CellView.HighlightPath
    

    @Binding var currentTheme: Theme
    
    var isSelected: Bool
    var cell: Puzzle.Cell

    var fixed: Bool { cell.fixed }
    var value: Int { cell.value }
    var guess: Int? { cell.guess }
    var notes: Set<Int> { cell.notes }
    
    // -------------------------------------
    var highlight: some View {
        CellView.highlightRect.opacity(currentTheme.highlightBrightness)
    }

    // -------------------------------------
    var displayString: String
    {
        if cell.fixed { return "\(cell.value)" }
        if let guess = self.guess {
            return "\(guess)"
        }
        return ""
    }
    
    // -------------------------------------
    var foreColor: Color
    {
        return Color( fixed
            ? currentTheme.valueColor
            : guess == value
                ? currentTheme.correctGuessColor
                : currentTheme.incorrectGuessColor
        )
    }
    
    // -------------------------------------
    var backColor: Color
    {
        return Color(fixed || guess == nil || guess == value
            ? currentTheme.backColor
            : currentTheme.incorrectBackColor
        )
    }

    // -------------------------------------
    var body: some View
    {
        ZStack
        {
            backColor
            if !fixed && isSelected { highlight }
            if !fixed && guess == nil
            {
                ThemeEditorCellNotesPreview(
                    notes: cell.notes,
                    currentTheme: $currentTheme
                )
            }
            else
            {
                Text(displayString)
                    .font(Font(currentTheme.font))
                    .foregroundColor(foreColor)
            }
        }
        .frame(width: Self.width, height: Self.height, alignment: .center)
    }
}
