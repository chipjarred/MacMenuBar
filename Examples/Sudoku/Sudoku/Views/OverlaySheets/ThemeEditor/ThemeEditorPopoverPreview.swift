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
struct ThemeEditorPopoverPreview: View
{
    private static let topPadding = CGSize(width: 0, height: 20)
    private static let rawSize = CellGroupView.size
        + CGSize(width: PopoverShape.arrowSize.height, height: 0)
    private static let scalingFactor: CGFloat = 0.8
    private static let scaledSize = rawSize * scalingFactor
    static let size = scaledSize + topPadding
    static let width = size.width
    static let height = size.height
    
    @Binding var currentTheme: Theme
    
    let settingNotes: Bool
    let arrowEdge: Edge
    
    let notes: Set<Int> = [1, 3, 5, 6, 8]
    let validGuesses: Set<Int> = [2, 8, 9]
    let correctValue = 8
    let guess: Int = 9

    // -------------------------------------
    func foreColor(for value: Int) -> Color
    {
        GuessSelectionView.foreColor(
            for: value,
            settingNotes: settingNotes,
            in: notes,
            isValidGuess: validGuesses.contains(value),
            isSelectedValue: guess == value,
            theme: currentTheme
        )
    }
    
    // -------------------------------------
    func isEnabled(for value: Int) -> Bool { validGuesses.contains(value) }
    
    // -------------------------------------
    func valueCell(row: Int, col: Int) -> some View
    {
        let value = row * 3 + col + 1
        return GuessSelectionView.valueCell(
            value: value,
            foreColor: foreColor(for: value),
            theme: currentTheme
        )
    }

    let x = NSVisualEffectView.Material.popover
    let y = NSAppearance.current
    
    // -------------------------------------
    func popoverView(arrowEdge: Edge) -> some View
    {
        PopoverPreviewBackground()
            .mask(PopoverShape(arrowEdge: arrowEdge))
    }
    
    // -------------------------------------
    var body: some View
    {
        ZStack
        {
            popoverView(arrowEdge: arrowEdge)
            
            HStack(alignment: .center, spacing: 0)
            {
                if arrowEdge == .leading
                {
                    Color.black.opacity(0)
                        .frame(width: PopoverShape.arrowSize.height)
                }
                
                VStack(spacing: 0)
                {
                    Text(settingNotes ? "Set Note" : "Set Guess")
                        .foregroundColor(.controlTextColor)
                        .padding([.top, .bottom], 1)

                    ForEach(0..<3)
                    { valueRow in
                        HStack(spacing:0)
                        {
                            ForEach(0..<3)
                            { valueCol in
                                valueCell(row: valueRow, col: valueCol)
                            }
                        }
                    }
                }
                .padding(.top, 10)
                
                if arrowEdge == .trailing
                {
                    Color.black.opacity(0)
                        .frame(width: PopoverShape.arrowSize.height)
                }
            }
        }.scaledToFit().scaleEffect(Self.scalingFactor)
    }
}

// -------------------------------------
struct ThemeEditorPopoverPreview_Previews: PreviewProvider
{
    @State static var theme = Theme.system
    
    static var previews: some View
    {
        ZStack
        {
            Color.controlColor
            HStack
            {
                ThemeEditorPopoverPreview(
                    currentTheme: $theme,
                    settingNotes: false,
                    arrowEdge: .leading
                )
                
                ThemeEditorPopoverPreview(
                    currentTheme: $theme,
                    settingNotes: false,
                    arrowEdge: .trailing
                )
            }
        }.frame(
            width: ThemeEditorPopoverPreview.width * 2 + 2,
            height: ThemeEditorPopoverPreview.height
        )
    }
}
