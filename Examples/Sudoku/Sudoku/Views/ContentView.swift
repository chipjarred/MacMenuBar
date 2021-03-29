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
class SheetRequest: ObservableObject
{
    static var shared: SheetRequest { AppDelegate.shared.sheetRequest }
    
    enum Request
    {
        case none
        case newGame
        case editThemes
    }
    
    @Published var state: Request = .none
}

// -------------------------------------
struct ContentView: View
{
    @State var puzzle = PuzzleObject()
    @ObservedObject var sheetRequest: SheetRequest
    @State var startNewGame = false
    @ObservedObject var prefs: Preferences
    
    static let borderWidth: CGFloat = 3
    static let width = PuzzleView.width + 2 * borderWidth
    static let height = width

    // -------------------------------------
    var body: some View
    {
        ZStack
        {
            Color(prefs.theme.borderColor)
            PuzzleView()
                .environmentObject(puzzle)
                .environmentObject(sheetRequest)
                .environmentObject(prefs)

            if sheetRequest.state == .newGame
            {
                NewGameRequestSheet()
                    .zIndex(2)
                    .environmentObject(puzzle)
                    .environmentObject(sheetRequest)
                    .environmentObject(prefs)
            }
            else if sheetRequest.state == .editThemes
            {
                ThemeEditor()
                    .environmentObject(sheetRequest)
                    .environmentObject(prefs)
            }
        }
        .frame(width: Self.width, height: Self.height, alignment: .center)
    }
}

// -------------------------------------
struct ContentView_Previews: PreviewProvider {
    static let prefs = Preferences()
    static var previews: some View {
        ContentView(sheetRequest: SheetRequest(), prefs: prefs)
    }
}
