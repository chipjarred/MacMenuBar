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
    static let width = CellGroupView.width
    static let height = CellGroupView.height + 20
    static let size = CGSize(width: width, height: height)
    
    @Binding var currentTheme: Theme
    
    let settingNotes: Bool
    
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

    
    // -------------------------------------
    var body: some View
    {
        ZStack
        {
            VStack(spacing: 0)
            {
                Text(settingNotes ? "Set Note" : "Set Guess")
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
        }.frame(Self.size)
    }
}

// -------------------------------------
struct ThemeEditorPopoversView: View
{
    @Binding var currentTheme: Theme
    @EnvironmentObject var prefs: Preferences
    @State var fakeState: Bool = true
    
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
            .frame(width: 100, height: 100)
    }
    
    // -------------------------------------
    var notesPopoverColumn: some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            HStack(alignment: .center)
            {
                VStack(spacing: 0)
                {
                    Text("Some Note Settings")
                }
                .frame(alignment: .leading)
                .popover(isPresented: $fakeState, arrowEdge: .trailing)
                {
                    ThemeEditorPopoverPreview(
                        currentTheme: $currentTheme,
                        settingNotes: true
                    ).onDisappear { fakeState = true }
                }
                
                invisibleRect(align: .trailing)
                    .frame(ThemeEditorPopoverPreview.size)
            }.frame(alignment: .leading)
            
            spacerRect()
        }
    }
    
    // -------------------------------------
    var guessPopoverColumn: some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            spacerRect()
            
            HStack(alignment: .center)
            {
                invisibleRect(align: .leading)
                    .frame(ThemeEditorPopoverPreview.size)
                
                VStack(spacing: 0)
                {
                    Text("Some Note Settings")
                }
                .frame(alignment: .trailing)
                .popover(isPresented: $fakeState, arrowEdge: .leading)
                {
                    ThemeEditorPopoverPreview(
                        currentTheme: $currentTheme,
                        settingNotes: false
                    ).onDisappear { fakeState = true }
                }

            }.frame(alignment: .trailing)
        }
    }
    
    // -------------------------------------
    var body: some View
    {
        ZStack
        {
            notesPopoverColumn
            guessPopoverColumn
        }
        .padding(.top, 10)
        .onAppear { fakeState = true }
    }
}
