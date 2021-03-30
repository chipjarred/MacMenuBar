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
struct GuessSelectionView: View
{
    static let keyResponder = KeyResponder()
    
    @EnvironmentObject var puzzle: PuzzleObject
    @EnvironmentObject var prefs: Preferences
    @Binding var showingPopover: Bool
    @Binding var settingNotes: Bool
    
    let row: Int
    let col: Int
    
    // -------------------------------------
    static func foreColor(
        for value: Int,
        settingNotes: Bool,
        in notes: Set<Int>,
        isValidGuess: Bool,
        isSelectedValue: Bool,
        theme: Theme) -> Color
    {
        if settingNotes
        {
            return Color(
                notes.contains(value)
                    ? theme.selectedNoteColor
                    : theme.unSelectedNoteColor
            )
        }
        else
        {
            return Color(
                isValidGuess
                    ? isSelectedValue
                        ? theme.actualGuessColor
                        : theme.validGuessColor
                    : theme.invalidGuessColor
            )
        }
    }
    
    // -------------------------------------
    func foreColor(for value: Int) -> Color
    {
        Self.foreColor(
            for: value,
            settingNotes: settingNotes,
            in: puzzle[row, col].notes,
            isValidGuess: puzzle.isValid(guess: value, forRow: row, col: col),
            isSelectedValue: puzzle[row, col].guess == value,
            theme: prefs.theme
        )
    }
    
    // -------------------------------------
    func isEnabled(for value: Int) -> Bool {
        return puzzle.isValid(guess: value, forRow: row, col: col)
    }
    
    // -------------------------------------
    var body: some View
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
        .onAppear() { Self.keyResponder.onKeyDown { handleKeyDown($0) } }
    }
    
    // -------------------------------------
    static func valueCell(value: Int, foreColor: Color, theme: Theme) -> some View
    {
        return Text("\(value)")
            .font(Font(theme.font))
            .foregroundColor(foreColor)
            .frame(CellView.frame)
    }

    // -------------------------------------
    func valueCell(row: Int, col: Int) -> some View
    {
        let value = row * 3 + col + 1
        return Self.valueCell(
            value: value,
            foreColor: foreColor(for: value),
            theme: prefs.theme
        ).gesture( TapGesture().onEnded { _ in handleGesture(for: value) } )
    }
    
    // -------------------------------------
    func handleGesture(for value: Int)
    {
        guard !puzzle[row, col].fixed else { return }
        defer { if !settingNotes { handleClosePopover() } }
        
        if settingNotes
        {
            if puzzle[row, col].notes.contains(value) {
                puzzle[row, col].notes.remove(value)
            }
            else { puzzle[row, col].notes.insert(value) }
        }
        else { puzzle[row, col].guess = value }
    }
    
    // -------------------------------------
    func handleClosePopover()
    {
        showingPopover = false
        settingNotes = false
        Self.keyResponder.resign()
    }
    
    // -------------------------------------
    func handleKeyDown(_ event: NSEvent) -> Bool
    {
        let escape = Character(Unicode.Scalar(0x1B))
        let badModifiers: NSEvent.ModifierFlags = settingNotes
            ? [.command, .function, .shift]
            : [.command, .option, .function, .shift]
        
        if handleNavigationKeys(for: event)
        {
            handleClosePopover()
            NSApp.sendEvent(event)
            return true
        }
        
        guard let chars = event.characters else { return false }
        
        if Character(chars) == escape
        {
            handleClosePopover()
            return true
        }
        
        guard let value = Int(chars),
           (1...9).contains(value),
           event.modifierFlags.intersection(badModifiers).isEmpty
        else { return false }
        
        handleGesture(for: value)
        return true
    }
    
    // -------------------------------------
    func handleNavigationKeys(for event: NSEvent) -> Bool
    {
        switch event.keyCode
        {
            case .kVK_Delete, .kVK_Tab, .kVK_Home, .kVK_End,
                 .kVK_RightArrow, .kVK_LeftArrow, .kVK_UpArrow, .kVK_DownArrow:
                return true

            default: return false
        }
    }
}

// -------------------------------------
struct GuessSelectionView_Previews: PreviewProvider {
    static var puzzle = previewPuzzle
    @State static var showingPopover = false
    @State static var settingNotes = false

    static var previews: some View
    {
        GuessSelectionView(
            showingPopover: $showingPopover,
            settingNotes: $settingNotes,
            row: 0,
            col: 0
        )
        .environmentObject(puzzle)
        .environmentObject(Preferences())
    }
}
