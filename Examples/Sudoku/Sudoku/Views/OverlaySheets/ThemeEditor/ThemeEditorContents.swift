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
struct ThemeSlider<FloatValue: BinaryFloatingPoint>: View
    where FloatValue.Stride: BinaryFloatingPoint
{
    var label: String
    @State var sliderValue: FloatValue
    @Binding var currentTheme: Theme
    let keyPath: WritableKeyPath<Theme, FloatValue>
    
    // -------------------------------------
    var body: some View
    {
        HStack(spacing: 0)
        {
            Text("\(label):")
                .font(.system(size: 10))
                .frame(alignment: .trailing)
                .padding([.leading, .trailing], 5)
            Slider(value: $sliderValue, in: 0.0...1.0) { _ in
                currentTheme[keyPath: keyPath] = sliderValue
            }.frame(width: 100)
        }
    }
}

// -------------------------------------
struct ThemeFontPicker: View
{
    static let sizes = [8, 9, 10, 11, 12, 14, 16, 18, 21, 24, 28, 30, 36, 48]
    var label: String
    @State var pickerValue: NSFont
    @State var size: Int
    @Binding var currentTheme: Theme
    let keyPath: WritableKeyPath<Theme, NSFont>
    
    // -------------------------------------
    var body: some View
    {
        HStack(alignment: .center, spacing: 0)
        {
            Text("\(label):")
                .font(.system(size: 10))
                .frame(alignment: .trailing)
                .padding(.trailing, 5)
                .padding(.top, 4)
            
            FontPopupButton<Theme>(
                width: 80,
                height: 25,
                stylableThing: $currentTheme,
                fontPath: keyPath
            ).frame(alignment: .trailing)
            
            Picker("Size:", selection: $size)
            {
                ForEach(Self.sizes, id: \.self) { points in
                    Text("\(points)").tag(points)
                }
            }
            .font(.system(size: 10))
            .frame(width: 80, height: 25)
            .padding(.top, 4)
        }.frame(width: 200)
    }
}

// -------------------------------------
struct ThemeEditorContents: View
{
    @Binding var currentTheme: Theme
    @EnvironmentObject var prefs: Preferences
    
    // -------------------------------------
    var cellPreviewStack: some View
    {
        let cells =
        [
            ThemeEditorCellPreview(
                currentTheme: $currentTheme,
                isSelected: false,
                cell: .init(
                    value: 5,
                    guess: nil,
                    fixed: true,
                    notes: []
                )
            ),
            ThemeEditorCellPreview(
                currentTheme: $currentTheme,
                isSelected: false,
                cell: .init(
                    value: 7,
                    guess: 7,
                    fixed: false,
                    notes: []
                )
            ),
            ThemeEditorCellPreview(
                currentTheme: $currentTheme,
                isSelected: true,
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
                    value: 1,
                    guess: 9,
                    fixed: false,
                    notes: []
                )
            ),
            ThemeEditorCellPreview(
                currentTheme: $currentTheme,
                isSelected: false,
                cell: .init(
                    value: 8,
                    guess: nil,
                    fixed: false,
                    notes: [1, 2, 6, 8, 9]
                )
            )
        ]
        
        let numCells = CGFloat(cells.count)
        let intercellSpacing: CGFloat = 2
        
       return ZStack
        {
            Rectangle().fill(Color(currentTheme.borderColor))
                .frame(
                    width: CellView.width + 2 * intercellSpacing,
                    height: (CellView.height + intercellSpacing) * numCells
                        + intercellSpacing
                )
            
            VStack(alignment: .center, spacing: 2) {
                ForEach(cells, id: \.value) { $0 }
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
                HStack(alignment: .top)
                {
                    cellPreviewStack
                    
                    VStack(alignment: .trailing, spacing: 2)
                    {
                        ThemeColorWell(
                            "Known Value Color",
                            currentTheme: $currentTheme,
                            colorPath: \.valueColor
                        )
                        ThemeColorWell(
                            "Background Color",
                            currentTheme: $currentTheme,
                            colorPath: \.backColor
                        )
                        ThemeColorWell(
                            "Border Color",
                            currentTheme: $currentTheme,
                            colorPath: \.borderColor
                        )
                        ThemeColorWell(
                            "Correct Guess Color",
                            currentTheme: $currentTheme,
                            colorPath: \.correctGuessColor
                        )
                        ThemeSlider(
                            label: "Highlight Intensity",
                            sliderValue: currentTheme.highlightBrightness,
                            currentTheme: $currentTheme,
                            keyPath: \.highlightBrightness
                        )
                        .padding([.top, .bottom], 2)
                        ThemeColorWell(
                            "Wrong Guess Color",
                            currentTheme: $currentTheme,
                            colorPath: \.incorrectGuessColor
                        )
                        ThemeColorWell(
                            "Wrong Guess Background Color",
                            currentTheme: $currentTheme,
                            colorPath: \.incorrectBackColor
                        )
                        ThemeColorWell(
                            "Note Color",
                            currentTheme: $currentTheme,
                            colorPath: \.noteColor
                        ).padding(.top, 10)
                    }
                }
                
                ThemeFontPicker(
                    label: "Value Font",
                    pickerValue: currentTheme.font,
                    size: Int(currentTheme.font.pointSize),
                    currentTheme: $currentTheme,
                    keyPath: \.font
                )
                
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
struct ThemeEditorContents_Previews: PreviewProvider
{
    static var prefs = Preferences()
    @State static var currentTheme = prefs.theme
    
    // -------------------------------------
    static var previews: some View
    {
        ThemeEditorContents(currentTheme: $currentTheme)
            .frame(
                width: PuzzleView.width - ThemeList.width,
                height: PuzzleView.width - ThemeEditor.titleHeight
            ).environmentObject(prefs)
    }
}
