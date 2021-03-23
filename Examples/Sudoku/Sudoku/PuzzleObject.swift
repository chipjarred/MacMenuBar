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

import AppKit

// -------------------------------------
final class PuzzleObject: ObservableObject, Codable
{
    public static var shared: PuzzleObject {
        AppDelegate.shared.puzzle
    }
    
    public typealias Cell = Puzzle.Cell
    @Published var puzzle: Puzzle
    {
        didSet { if recordUndo { saveToUndoHistory() } }
    }
    
    /*
     UndoManager is more of a heavy-weight undo system than we really need, so
     we just roll our own simple one.  Because the game is sufficiently small,
     we can just save the entire game state in the history.  No need to
     memoize individual actions.
     
     The way the undo history works is that `undoIndex` always points to a copy
     of the *current* state.
     
     When we `undo`, the state we want to restore is at `undoIndex - 1`,
     assuming that location exists.
     
     When we `redo`, the state we want to restore is at `undoIndex + 1`,
     assuming that location exists.
     
     When we record an action, we remove all the elements in `undoHistory` after
     `undoIndex`, which clears the `redo` portion of the history. From the
     user's perspective, undoing and then making a move doesn't allow redoing
     to some state that no longer makes sense.
     
     We don't have an undo history size limit.
     
     So the system is pretty simple to implement.  It does mean that we always
     have a two copies of the current game state, one in `puzzle` and one in
     `undoHistory`, which is wasteful, and could be a problem if this were a
     more complex game than Sudoku.
     
     We don't undo/redo theme or other preference changes with this system.
     It's purely a game state thing.  We also don't undo selections. 
     */
    private var recordUndo = true
    private var undoHistory: [Puzzle]
    private var undoIndex: Int
    
    public var bookmark: URLBookmark? = nil {
        didSet {  AppDelegate.shared.updateWindowTitle(with: name) }
    }
    public let fileExtension = "sudoku"
    public var untitledName: String { "Untitled" }
    
    // -------------------------------------
    public func save(from savePanel: NSSavePanel)
    {
        do
        {
            // When we save using save panel, we must write to the URL before we
            // can obtain a bookmark from it, otherwise the attempt to acquire
            // the bookmark throws.
            let data = try JSONEncoder().encode(self)
            guard let url = savePanel.url else
            {
                throw NSError(
                    domain: NSCocoaErrorDomain,
                    code: NSFileWriteNoPermissionError
                )
            }
            try data.write(to: url)
            self.bookmark = try URLBookmark(url: url)
            Preferences.shared.addRecent(bookmark: bookmark!)
        }
        catch
        {
            AppDelegate.shared.errorAlert(
                "Unable to save game",
                moreText: "\(error.localizedDescription)"
            )
        }
    }
    
    // -------------------------------------
    public func save(to bookmark: URLBookmark)
    {
        do
        {
            let data = try JSONEncoder().encode(self)
            try bookmark.fileWrite(data: data)
            self.bookmark = bookmark
            Preferences.shared.addRecent(bookmark: bookmark)
        }
        catch
        {
            AppDelegate.shared.errorAlert(
                "Unable to save game",
                moreText: "\(error.localizedDescription)"
            )
        }
    }
    
    // -------------------------------------
    public func load(from openPanel: NSOpenPanel)
    {
        do
        {
            // When we load using open panel, we must read from the URL before
            // we can obtain a bookmark from it, otherwise the attempt to
            // acquire the bookmark throws.
            guard let url = openPanel.url else
            {
                throw NSError(
                    domain: NSCocoaErrorDomain,
                    code: NSFileReadNoPermissionError
                )
            }
            let data = try Data(contentsOf: url)
            let p = try JSONDecoder().decode(PuzzleObject.self, from: data)
            
            self.bookmark = try URLBookmark(url: url)
            self.undoHistory = p.undoHistory
            self.undoIndex = p.undoIndex
            self.puzzle = p.puzzle
            Preferences.shared.addRecent(bookmark: bookmark!)
        }
        catch
        {
            AppDelegate.shared.errorAlert(
                "Unable to load game",
                moreText: "\(error.localizedDescription)"
            )
        }
    }
    
    // -------------------------------------
    public func load(from bookmark: URLBookmark)
    {
        do
        {
            let data = try bookmark.fileRead()
            let p = try JSONDecoder().decode(PuzzleObject.self, from: data)
            
            self.bookmark = bookmark
            self.undoHistory = p.undoHistory
            self.undoIndex = p.undoIndex
            self.puzzle = p.puzzle
            Preferences.shared.addRecent(bookmark: bookmark)
        }
        catch
        {
            AppDelegate.shared.errorAlert(
                "Unable to load game",
                moreText: "\(error.localizedDescription)"
            )
        }
    }

    // -------------------------------------
    public var name: String
    {
        let baseEnd = baseName.index(
            baseName.endIndex,
            offsetBy: -(fileExtension.count + 1)
        )
        
        return String(baseName[..<baseEnd])
    }
    
    // -------------------------------------
    public var directoryURL: URL {
        return bookmark?.deletingPathExtension() ?? defaultSaveDir
    }
    
    // -------------------------------------
    private var defaultSaveDir: URL
    {
        let paths = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // -------------------------------------
    public var baseName: String
    {
        if let baseName = bookmark?.pathComponents.last,
           baseName.hasSuffix(".\(fileExtension)")
        {
            return baseName
        }
        else { return "\(untitledName).\(fileExtension)" }
    }
    
    // -------------------------------------
    init()
    {
        let p = Puzzle()
        self.puzzle = p
        self.undoHistory = [p]
        self.undoIndex = 0
    }
        
    // -------------------------------------
    public subscript(row: Int, col: Int) -> Cell
    {
        get { puzzle[row, col] }
        set { puzzle[row, col] = newValue }
    }
    
    // -------------------------------------
    public var selection: (row: Int, col: Int)?
    {
        get { puzzle.selection }
        set { withoutRecordingUndo { puzzle.selection = newValue } }
    }
    
    // -------------------------------------
    public func isValid(guess: Int, forRow row: Int, col: Int) -> Bool {
        puzzle.isValid(guess: guess, forRow: row, col: col)
    }
    
    // -------------------------------------
    public func newPuzzle()
    {
        bookmark = nil
        puzzle = Puzzle()
        resetUndo()
    }
    
    // -------------------------------------
    public var hasStarted: Bool
    {
        puzzle.cells.reduce(false) {
            $0 || ($1.guess != nil || $1.notes.count > 0)
        }
    }
    
    // -------------------------------------
    public var canUndo: Bool { undoIndex > 0 }
    
    // -------------------------------------
    public var canRedo: Bool { undoHistory.count - undoIndex > 1 }
    
    // -------------------------------------
    public func undo()
    {
        withoutRecordingUndo
        {
            guard canUndo else { return }
            let s = puzzle.selection
            undoIndex -= 1
            puzzle = undoHistory[undoIndex]
            puzzle.selection = s
        }
    }
    
    // -------------------------------------
    public func redo()
    {
        withoutRecordingUndo
        {
            guard canRedo else { return }
            let s = puzzle.selection
            undoIndex += 1
            puzzle = undoHistory[undoIndex]
            puzzle.selection = s
        }
    }
    
    // -------------------------------------
    public func resetUndo()
    {
        undoHistory.removeAll(keepingCapacity: true)
        undoHistory.append(puzzle)
        undoIndex = 0
    }
    
    // -------------------------------------
    private func saveToUndoHistory()
    {
        undoIndex += 1
        let numToRemove = undoHistory.count - undoIndex
        
        if numToRemove > 0 {
            undoHistory.removeLast(numToRemove)
        }
        
        undoHistory.append(puzzle)
    }
    
    // -------------------------------------
    private func withoutRecordingUndo<R>(do block: () throws -> R) rethrows -> R
    {
        let savedRecordUndo = recordUndo
        recordUndo = false
        defer { recordUndo = savedRecordUndo }
        
        return try block()
    }
    
    
    // MARK:- Codable Conformance
    // -------------------------------------
    public enum CodingKey: Swift.CodingKey
    {
        case puzzle
        case undoHistory
        case undoIndex
    }
    
    // -------------------------------------
    public required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKey.self)
        self.puzzle = try container.decode(Puzzle.self, forKey: .puzzle)
        self.undoHistory =
            try container.decode([Puzzle].self, forKey: .undoHistory)
        self.undoIndex = try container.decode(Int.self, forKey: .undoIndex)
    }
    
    // -------------------------------------
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKey.self)
        try container.encode(puzzle, forKey: .puzzle)
        try container.encode(undoHistory, forKey: .undoHistory)
        try container.encode(undoIndex, forKey: .undoIndex)
    }
}

// MARK:- Navigation
// -------------------------------------
extension PuzzleObject
{
    // -------------------------------------
    func selectNext()
    {
        withoutRecordingUndo
        {
            guard let (r, c) = selection else
            {
                selectFirst()
                return
            }
            
            let end = r * 9 + c
            var i = (end + 1) % 81

            repeat
            {
                if puzzle.cells[i].isAutoSelectable
                {
                    selection = (i / 9, i % 9)
                    return
                }
                i = (i + 1) % 81
            } while i != end
        }
    }
    
    // -------------------------------------
    func selectPrev()
    {
        withoutRecordingUndo
        {
            guard let (r, c) = selection else
            {
                selectLast()
                return
            }
            
            let end = r * 9 + c
            var i = (end + 80) % 81

            repeat
            {
                if puzzle.cells[i].isAutoSelectable
                {
                    selection = (i / 9, i % 9)
                    return
                }
                i = (i + 80) % 81
            } while i != end
        }
    }
    
    // -------------------------------------
    func selectFirst()
    {
        withoutRecordingUndo
        {
            for i in puzzle.cells.indices
            {
                if puzzle.cells[i].isAutoSelectable
                {
                    selection = (i / 9, i % 9)
                    return
                }
            }
        }
    }
    
    // -------------------------------------
    func selectLast()
    {
        withoutRecordingUndo
        {
            for i in puzzle.cells.indices.reversed()
            {
                if puzzle.cells[i].isAutoSelectable
                {
                    selection = (i / 9, i % 9)
                    return
                }
            }
        }
    }
    
    // -------------------------------------
    func selectFirst(inRow row: Int)
    {
        withoutRecordingUndo
        {
            for col in puzzle.rowIndices
            {
                if self[row, col].isAutoSelectable
                {
                    selection = (row, col)
                    return
                }
            }
        }
    }
    
    // -------------------------------------
    func selectLast(inRow row: Int)
    {
        withoutRecordingUndo
        {
            for col in puzzle.rowIndices.reversed()
            {
                if self[row, col].isAutoSelectable
                {
                    selection = (row, col)
                    return
                }
            }
        }
    }
    
    // -------------------------------------
    func selectFirst(inCol col: Int)
    {
        withoutRecordingUndo
        {
            for row in puzzle.rowIndices
            {
                if self[row, col].isAutoSelectable
                {
                    selection = (row, col)
                    return
                }
            }
        }
    }
    
    // -------------------------------------
    func selectLast(inCol col: Int)
    {
        withoutRecordingUndo
        {
            for row in puzzle.rowIndices.reversed()
            {
                if self[row, col].isAutoSelectable
                {
                    selection = (row, col)
                    return
                }
            }
        }
    }
    
    // -------------------------------------
    func selectNextVertical()
    {
        withoutRecordingUndo
        {
            guard var (row, col) = selection else
            {
                selectFirst()
                return
            }
            
            for _ in 0..<81
            {
                row += 1
                if row == 9
                {
                    row = 0
                    col = (col + 1) % 9
                }
                
                if self[row, col].isAutoSelectable
                {
                    selection = (row, col)
                    return
                }
            }
        }
    }
    
    // -------------------------------------
    func selectPrevVertical()
    {
        withoutRecordingUndo
        {
            guard var (row, col) = selection else
            {
                selectFirst()
                return
            }
            
            for _ in 0..<81
            {
                row -= 1
                if row == -1
                {
                    row = 8
                    col = (col + 8) % 9
                }
                
                if self[row, col].isAutoSelectable
                {
                    selection = (row, col)
                    return
                }
            }
        }
    }
}
