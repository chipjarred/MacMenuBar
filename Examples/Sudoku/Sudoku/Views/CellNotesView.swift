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
struct CellNotesView: View
{
    @EnvironmentObject var puzzle: PuzzleObject
    @EnvironmentObject var prefs: Preferences
    let row: Int
    let col: Int
    
    // -------------------------------------
    func note(_ noteRow: Int, _ noteCol: Int) -> Int?
    {
        let noteValue = 3 * noteRow + noteCol + 1
        return puzzle[row, col].notes.contains(noteValue) ? noteValue : nil
    }

    // -------------------------------------
    var body: some View
    {
        VStack(spacing:0)
        {
            ForEach(0..<3)
            { noteRow in
                HStack(spacing: 0)
                {
                    ForEach(0..<3)
                    { noteCol in
                        CellNoteView(note: note(noteRow, noteCol))
                            .environmentObject(prefs)
                    }
                }
                .scaledToFit()
            }
        }
        .scaledToFit()
    }
}

// -------------------------------------
internal let previewPuzzle: PuzzleObject =
{
    let p = PuzzleObject()
    for i in p.puzzle.cells.indices {
        p.puzzle.cells[i].notes = Set(1...9)
    }
    let i = p.puzzle.cells.firstIndex { !$0.fixed && $0.guess == nil }!
    p.selection = (i / 9, i % 9)
    return p
}()

// -------------------------------------
struct CellNotesView_Previews: PreviewProvider
{
    static var puzzle = previewPuzzle
    
    static var previews: some View
    {
        CellNotesView(row: 0, col: 0)
            .environmentObject(puzzle)
            .environmentObject(Preferences())
    }
}
