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
struct CellGroupView: View
{
    @EnvironmentObject var puzzle: PuzzleObject
    @EnvironmentObject var prefs: Preferences

    static let cellSpacing: CGFloat = 1
    static let width = CellView.width * 3 + cellSpacing * 2
    static let height = width
    
    let row: Int
    let col: Int
    
    // -------------------------------------
    var body: some View
    {
        VStack(spacing: Self.cellSpacing)
        {
            ForEach(0..<3)
            { i in
                HStack(spacing: Self.cellSpacing)
                {
                    ForEach(0..<3)
                    { j in
                        CellView(
                            row: row * 3 + i,
                            col: col * 3 + j
                        )
                        .environmentObject(puzzle)
                        .environmentObject(prefs)
                    }
                }
            }
        }
    }
}

// -------------------------------------
struct CellGroupView_Previews: PreviewProvider
{
    @State static var puzzle =  previewPuzzle
    
    // -------------------------------------
    static var previews: some View
    {
        CellGroupView(row: 0, col: 0 )
            .environmentObject(previewPuzzle)
            .environmentObject(Preferences())
    }
}
