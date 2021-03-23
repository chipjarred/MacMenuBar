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

import Foundation

// -------------------------------------
struct Puzzle
{
    // -------------------------------------
    struct Cell
    {
        var value: Int
        var guess: Int? = nil
        var fixed: Bool
        var notes: Set<Int> = []
        
        // -------------------------------------
        func matches(guess: Int) -> Bool
        {
            let result = (fixed && value == guess) || (!fixed && guess == self.guess)

            return result
        }
    }
    
    var cells = [Cell](
        repeating: Cell(value: 0, guess: nil, fixed: true),
        count: 9 * 9
    )
    
    var rowIndices: Range<Int> { 0..<9 }
    
    var selection: (row: Int, col: Int)? = nil
    var selectedCell: Cell?
    {
        if let s = selection { return self[s.row, s.col] }
        return nil
    }
    
    // -------------------------------------
    subscript(row: Int, col: Int) -> Cell
    {
        get { cells[row * 9 + col] }
        set
        {
            let index = row * 9 + col
        
            if let guess = newValue.guess,
                newValue.guess != cells[index].guess
            {
                clearValueFromNotes(guess, row: row, col: col)
            }
            
            cells[index]  = newValue
        }
    }
    
    // -------------------------------------
    mutating func clearValueFromNotes(_ note: Int, row: Int, col: Int)
    {
        for c in rowIndices {
            self[row, c].notes.remove(note)
        }
        
        for r in rowIndices {
            self[r, col].notes.remove(note)
        }
        
        let rowStart = row / 3
        let colStart = col / 3
        
        for r in rowStart..<(rowStart + 3)
        {
            for c in colStart..<(colStart + 3) {
                self[r, c].notes.remove(note)
            }
        }
    }
    
    // -------------------------------------
    init()
    {
        populateWithConsecutiveValues()
        randomize(iterations: 1)
        clearRandomCellsForPlay(count: 27)
    }
    
    // -------------------------------------
    func isValid(guess: Int, forRow row: Int, col: Int) -> Bool
    {
        // Check against the row
        for c in rowIndices {
            if self[row, c].matches(guess: guess) { return false }
        }
        
        // check against the column
        for r in rowIndices
        {
            guard r != row else { continue }
            if self[r, col].matches(guess: guess) { return false }
        }
        
        // check against the group
        let rowStart = (row / 3) * 3
        let colStart = (col / 3) * 3
        
        for r in rowStart..<(rowStart + 3)
        {
            for c in colStart..<(colStart + 3)
            {
                guard (r, c) != (row, col) else { continue }
                if self[r, c].matches(guess: guess) { return false }
            }
        }
        
        return true
    }
    
    // -------------------------------------
    var isSolved: Bool {
        cells.reduce(true) { $0 && ($1.fixed || $1.guess == $1.value) }
    }

    // -------------------------------------
    private mutating func populateWithConsecutiveValues()
    {
        for row in 0..<9
        {
            for col in 0..<9 {
                self[row, col].value = ((row / 3) * 4 + row * 3 + col) % 9 + 1
            }
        }
    }
    
    // -------------------------------------
    private mutating func clearRandomCellsForPlay(count: Int)
    {
        for _ in 0..<count
        {
            var row: Int
            var col: Int
            
            repeat
            {
                row = Int.random(in: rowIndices)
                col = Int.random(in: rowIndices)
            } while !self[row, col].fixed
            
            self[row, col].fixed = false
        }
    }
    
    // -------------------------------------
    private func setNotes(in cells: inout [Cell])
    {
        // Start with notes for all numbers in all cells
        for i in cells.indices {
            cells[i].notes = Set(0...9)
        }
        
        var curSet = Set<Int>()
        curSet.reserveCapacity(9)
        
        // Clear notes for solved numbers in the row
        for row in rowIndices
        {
            let rowOffset = row * 9
            
            curSet.removeAll(keepingCapacity: true)
            
            // Collect solved numbers in row
            for col in rowIndices
            {
                let cell = cells[rowOffset + col]
                if cell.fixed || cell.guess == cell.value {
                    curSet.insert(cell.value)
                }
            }
            
            // Remove solved numbers notes in unsolved cells in row
            for col in rowIndices
            {
                let index = rowOffset + col
                guard !cells[index].fixed else { continue }
                cells[index].notes.subtract(curSet)
            }
        }
        
        // Clear notes for solved numbers in the column
        for col in rowIndices
        {
            curSet.removeAll(keepingCapacity: true)
            
            // Collect solved numbers in column
            var rowStart = 0
            for _ in rowIndices
            {
                let cell = cells[rowStart + col]
                if cell.fixed || cell.guess == cell.value {
                    curSet.insert(cell.value)
                }
                rowStart += 9
            }
            
            // Remove solved numbers notes in unsolved cells in column
            rowStart = 0
            for _ in rowIndices
            {
                let index = rowStart + col
                if !cells[index].fixed {
                    cells[index].notes.subtract(curSet)
                }
                rowStart += 9
            }
        }
        
        // Clear notes for solved numbers in the group
        for group in 0..<9
        {
            curSet.removeAll(keepingCapacity: true)
            
            let rowStart = self.rowStart(for: group)
            let colStart = self.colStart(for: group)

            // Collect solved numbers in group
            for row in rowStart..<(rowStart + 3)
            {
                let rowStart = row * 9
                for col in colStart..<(colStart + 3)
                {
                    let cell = cells[rowStart + col]
                    if cell.fixed || cell.guess == cell.value {
                        curSet.insert(cell.value)
                    }
                }
            }
            
            // Remove solved numbers notes in unsolved cells in group
            for row in rowStart..<(rowStart + 3)
            {
                let rowStart = row * 9
                for col in colStart..<(colStart + 3)
                {
                    let index = rowStart + col
                    if !cells[index].fixed {
                        cells[index].notes.subtract(curSet)
                    }
                }
            }
        }
    }
    
    // -------------------------------------
    private mutating func randomize(iterations: Int)
    {
        for _ in 0..<iterations
        {
            for group in 0..<9
            {
                let rowStart = self.rowStart(for: group)
                let colStart = self.colStart(for: group)

                swapsRows(
                    rowStart + Int.random(in: 0..<3),
                    rowStart + Int.random(in: 0..<3)
                )
                swapsCols(
                    colStart + Int.random(in: 0..<3),
                    colStart + Int.random(in: 0..<3)
                )
            }
        }
        
        assert(checkInitValues(), "Bad initial values!")
    }
    
    // -------------------------------------
    private mutating func swapsRows(_ r1: Int, _ r2: Int)
    {
        assert(r1 / 3 == r2 / 3)
        guard r1 != r2 else { return }
        
        let r1Start = r1 * 9
        let r2Start = r2 * 9
        
        for col in 0..<9 {
            cells.swapAt(r1Start + col, r2Start + col)
        }
        assert(checkInitValues(), "Bad initial values!")
    }
    
    // -------------------------------------
    private mutating func swapsCols(_ c1: Int, _ c2: Int)
    {
        assert(c1 / 3 == c2 / 3)
        guard c1 != c2 else { return }
        
        var rowStart = 0
        for _ in 0..<9
        {
            cells.swapAt(rowStart + c1, rowStart + c2)
            rowStart += 9
        }
    }
    
    // -------------------------------------
    private func checkInitValues() -> Bool
    {
        let expected = Set<Int>(1...9)
        
        var curSet = Set<Int>()
        curSet.reserveCapacity(9)

        // Check rows
        for row in rowIndices
        {
            curSet.removeAll(keepingCapacity: true)
            for col in rowIndices {
                curSet.insert(self[row, col].value)
            }
            
            guard curSet == expected else { return false }
        }
        
        // Check columns
        for col in rowIndices
        {
            curSet.removeAll(keepingCapacity: true)
            for row in rowIndices {
                curSet.insert(self[row, col].value)
            }
            
            guard curSet == expected else { return false }
        }
        
        // Check groups
        for group in 0..<9
        {
            let rowStart = self.rowStart(for: group)
            let colStart = self.colStart(for: group)

            curSet.removeAll(keepingCapacity: true)
            for row in rowStart..<(rowStart + 3)
            {
                for col in colStart..<(colStart + 3)  {
                    curSet.insert(self[row, col].value)
                }
            }
            
            guard curSet == expected else { return false }
        }
        
        return true
    }
    
    // -------------------------------------
    private func rowStart(for group: Int) -> Int
    {
        assert((0..<9).contains(group))
        return (group % 3) * 3
    }
    
    // -------------------------------------
    private func colStart(for group: Int) -> Int
    {
        assert((0..<9).contains(group))
        return (group / 3) * 3
    }
    
    // -------------------------------------
    private func printPuzzle()
    {
        var s = "\n"
        for row in rowIndices
        {
            if row == 3 || row == 6 { s += "\n" }
            s += "    "
            for col in rowIndices
            {
                if col == 3 || col == 6 { s += " " }
                let cell = self[row, col]
                s += cell.fixed ? "\(self[row, col].value)" : "?"
            }
            
            s += "\n"
        }
        
        print(s)
    }
}

// -------------------------------------
extension Puzzle.Cell
{
    var isAutoSelectable: Bool
    {
        return !fixed
    }
}

// MARK:- Codable Conformance
// -------------------------------------
extension Puzzle.Cell: Codable { }

// -------------------------------------
extension Puzzle: Codable
{
    enum CodingKey: Swift.CodingKey
    {
        case cells
        case selectedRow
        case selectedCol
    }
    
    // -------------------------------------
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKey.self)
        self.cells = try container.decode([Cell].self, forKey: .cells)
        
        if let selectedRow =
            try container.decode(Int?.self, forKey: .selectedRow),
           let selectedCol =
            try container.decode(Int?.self, forKey: .selectedCol)
        {
            self.selection = (selectedRow, selectedCol)
        }
        else { self.selection = nil }
    }
    
    // -------------------------------------
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKey.self)
        try container.encode(cells, forKey: .cells)
        try container.encode(selection?.row, forKey: .selectedRow)
        try container.encode(selection?.col, forKey: .selectedCol)
    }
}
