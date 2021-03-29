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
struct CellView: View
{
    let keyResponder = KeyResponder()
    static let width: CGFloat = 40
    static var height: CGFloat { width }
    static let frame = CGSize(width: width, height: height)
    static let gradient = LinearGradient(
        gradient: Gradient(colors: [.black, .white]),
        startPoint: .bottom,
        endPoint: .top
    )

    // -------------------------------------
    struct HighlightPath: Shape
    {
        var minX: CGFloat = 0
        var minY: CGFloat = 0
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        
        func path(in rect: CGRect) -> Path
        {
            let w = rect.width / 6
            var path = Path()

            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + w, y: rect.minY + w))
            path.addLine(to: CGPoint(x: rect.maxX - w, y: rect.minY + w))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

            return path
        }
    }

    // -------------------------------------
    var highlight: some View {
        Self.highlightRect.opacity(prefs.theme.highlightBrightness)
    }
    
    // -------------------------------------
    static var highlightRect: some View
    {
        let hlGradient = Gradient(colors: [.white, .black, .black, .black])
        let maskOpacity: Double = 1
        
        return ZStack
        {
            VStack(spacing: 0)
            {
                Rectangle().opacity(0)
                    .overlay(
                        HighlightPath().fill(
                            LinearGradient(
                                gradient: hlGradient,
                                startPoint: .top,
                                endPoint: .center)
                        )
                        .opacity(maskOpacity)
                    )
                    .overlay(
                        HighlightPath().rotation(Angle(degrees: 180)).fill(
                            LinearGradient(
                                gradient: hlGradient,
                                startPoint: .bottom,
                                endPoint: .center)
                        )
                        .opacity(maskOpacity)
                    )
            }
            
            HStack(spacing: 0)
            {
                Rectangle().opacity(0)
                    .overlay(
                        HighlightPath().rotation(Angle(degrees: 90)).fill(
                                LinearGradient(
                                    gradient: hlGradient,
                                    startPoint: .trailing,
                                    endPoint: .center)
                            )
                        .opacity(maskOpacity)
                    )
                    .overlay(
                        HighlightPath().rotation(Angle(degrees: -90)).fill(
                            LinearGradient(
                                gradient: hlGradient,
                                startPoint: .leading,
                                endPoint: .center)
                        )
                        .opacity(maskOpacity)
                    )
            }
        }
    }

    @EnvironmentObject var puzzle: PuzzleObject
    @EnvironmentObject var prefs: Preferences
    @State var showingPopover: Bool = false
    @State var settingNotes: Bool = false
    
    let row: Int
    let col: Int
    
    // -------------------------------------
    var isSelected: Bool
    {
        if let s = puzzle.selection {
            return s == (row, col)
        }
        return false
    }
    
    // -------------------------------------
    var cell: Puzzle.Cell
    {
        get { puzzle[row, col] }
        set { puzzle[row, col] = newValue }
    }
    
    // -------------------------------------
    var fixed: Bool { cell.fixed }
    
    // -------------------------------------
    var value: Int
    {
        get { cell.value }
        set { cell.value = newValue }
    }

    // -------------------------------------
    var guess: Int?
    {
        get { cell.guess }
        set { cell.guess = newValue }
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
            ? prefs.theme.valueColor
            : guess == value
                ? prefs.theme.correctGuessColor
                : prefs.theme.incorrectGuessColor
        )
    }
    
    // -------------------------------------
    var backColor: Color
    {
        return Color(fixed || guess == nil || guess == value
            ? prefs.theme.backColor
            : prefs.theme.incorrectBackColor
        )
    }
    
    // -------------------------------------
    func popoverEdge() -> Edge {
        .trailing
    }
    
    // -------------------------------------
    var body: some View
    {
        ZStack
        {
            backColor
            if !fixed && isSelected { highlight }
            if !fixed && guess == nil {
                CellNotesView(row: row, col: col)
                    .environmentObject(puzzle)
                    .environmentObject(prefs)
                    .onAppear() {
                        keyResponder.onKeyDown { handleKeyDown($0) }
                    }
            }
            else
            {
                Text(displayString)
                    .font(Font(prefs.theme.font))
                    .foregroundColor(foreColor)
                    .onAppear() {
                        keyResponder.onKeyDown { handleKeyDown($0) }
                    }
            }
        }
        .frame(width: Self.width, height: Self.height, alignment: .center)
        .popover(isPresented: $showingPopover, arrowEdge: popoverEdge())
        {
            GuessSelectionView(
                showingPopover: $showingPopover,
                settingNotes: $settingNotes,
                row: row,
                col: col
            )
            .environmentObject(puzzle)
            .environmentObject(prefs)
        }
        .gesture(TapGesture().modifiers([.option, .control]).onEnded
            { _ in
                handleGesture(forNotes: true)
            }
        )
        .gesture(TapGesture().modifiers([.option]).onEnded
            { _ in
                handleGesture(forNotes: true)
            }
        )
        .gesture(TapGesture().modifiers(.control).onEnded
            { _ in
                handleGesture(forNotes: false)
            }
        )
        .gesture(TapGesture().modifiers(.command).onEnded
            { _ in
                handleGesture(forNotes: false)
            }
        )
        .gesture(TapGesture().onEnded
            {
                if fixed {
                    handleClearSelection()
                }
                else { puzzle.selection = (row, col) }
            }
        )
    }
    
    // -------------------------------------
    func handleGesture(forNotes: Bool, guess: Int? = nil)
    {
        if fixed {
            handleClearSelection()
        }
        else if let guess = guess
        {
            if forNotes {
                handleNote(guess, selection: (row, col))
            }
            else { handleGuess(guess, selection: (row, col)) }
        }
        else {
            handleShowPopoverClick(forNotes: forNotes, selection: (row, col))
        }
    }
    
    // -------------------------------------
    func handleGuess(_ guess: Int, selection: (row: Int, col: Int)) {
        puzzle[selection.row, selection.col].guess = guess
    }
    
    // -------------------------------------
    func handleNote(_ note: Int, selection: (row: Int, col: Int))
    {
        guard puzzle[selection.row, selection.col].guess == nil else { return }
        
        if puzzle[selection.row, selection.col].notes.contains(note) {
            puzzle[selection.row, selection.col].notes.remove(note)
        }
        else { puzzle[selection.row, selection.col].notes.insert(note) }
    }
    
    // -------------------------------------
    func handleShowPopoverClick(
        forNotes: Bool,
        selection: (row: Int, col: Int))
    {
        guard !forNotes || guess == nil else { return }
        
        puzzle.selection = (selection.row, selection.col)
        settingNotes = forNotes
        showingPopover = true
    }
    
    // -------------------------------------
    func handleClearSelection() {
        puzzle.selection = nil
    }

    // -------------------------------------
    func handleKeyDown(_ event: NSEvent) -> Bool
    {
        let backspace = Character(Unicode.Scalar(NSBackspaceCharacter)!)
        let delete = Character(Unicode.Scalar(NSDeleteCharacter)!)
        
        let badModifiers: NSEvent.ModifierFlags = [.command, .function, .shift]
        
        if handleNavigationKeys(for: event) { return true }
        
        guard let chars = event.characters, !chars.isEmpty else { return false }
        
        switch Character(chars)
        {
            case backspace, delete:
                handleDelete()
                return true
                
            default: break
        }
        
        guard let selection = puzzle.selection,
              let value = Int(chars),
              (1...9).contains(value),
              event.modifierFlags.intersection(badModifiers).isEmpty
        else { return false }
        
        if event.modifierFlags.contains(.option) {
            handleNote(value, selection: selection)
        }
        else { handleGuess(value, selection: selection) }
        
        return true
    }
    
    // -------------------------------------
    func handleDelete()
    {
        guard let (row, col) = puzzle.selection, !puzzle[row, col].fixed else {
            return
        }
        
        if puzzle[row, col].guess != nil {
            puzzle[row, col].guess = nil
        }
        else { puzzle[row, col].notes.removeAll(keepingCapacity: true) }
    }
    
    // -------------------------------------
    func handleNavigationKeys(for event: NSEvent) -> Bool
    {
        
        switch event.keyCode
        {
            case .kVK_Delete:
                handleDelete()
                
            case .kVK_Tab:
                if event.modifierFlags.contains(.shift) {
                    puzzle.selectPrev()
                }
                else { puzzle.selectNext() }
                
            case .kVK_Home:
                puzzle.selectFirst()
                
            case .kVK_End:
                puzzle.selectLast()

            case .kVK_RightArrow:
                if event.modifierFlags.contains(.command) {
                    puzzle.selectLast(inRow: row)
                }
                else { puzzle.selectNext() }
                
            case .kVK_LeftArrow:
                if event.modifierFlags.contains(.command) {
                    puzzle.selectFirst(inRow: row)
                }
                else { puzzle.selectPrev() }
                
            case .kVK_UpArrow:
                if event.modifierFlags.contains(.command) {
                    puzzle.selectFirst(inCol: col)
                }
                else { puzzle.selectPrevVertical() }
                
            case .kVK_DownArrow:
                if event.modifierFlags.contains(.command) {
                    puzzle.selectLast(inCol: col)
                }
                else { puzzle.selectNextVertical() }

            default: return false
        }
        
        return true
    }
}

// -------------------------------------
struct CellView_Previews: PreviewProvider
{
    static var puzzle = previewPuzzle
    
    // -------------------------------------
    static var previews: some View
    {
        CellView(row: 0, col: 0).environmentObject(Preferences())
    }
}
