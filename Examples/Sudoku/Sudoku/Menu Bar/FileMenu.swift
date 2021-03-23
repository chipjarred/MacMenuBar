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
import MacMenuBar

// -------------------------------------
let fileMenu = StandardMenu(title: "File")
{
    TextMenuItem(title: "New Game", keyEquivalent: .command + "n") { _ in
        AppDelegate.shared.newGame()
    }
    .enabledWhen { SheetRequest.shared.state == .none }
    
    TextMenuItem(title: "Open...", keyEquivalent: .command + "o") { sender in
        AppDelegate.shared.openDocument(sender)
    }
    StandardMenu(title: "Open Recent...")
    {
        ForEach(Preferences.shared.recentBookmarks)
        { bookmark in
            TextMenuItem(title: bookmark.deletingPathExtension().lastPathComponent)
            { _ in
                PuzzleObject.shared.load(from: bookmark)
            }
        }
    }
    
    MenuSeparator()
    
    TextMenuItem(title: "Save", keyEquivalent: .command + "s") { sender in
        AppDelegate.shared.save(sender)
    }.updatingTitleWith {
        PuzzleObject.shared.bookmark == nil ? "Save..." : "Save"
    }
    
    TextMenuItem(title: "Save As...", keyEquivalent: .command + "a") { sender in
        AppDelegate.shared.saveTo(sender)
    }
    TextMenuItem(title: "Revert to Saved", keyEquivalent: .command + "r")
    { sender in
        PuzzleObject.shared.load(from: PuzzleObject.shared.bookmark!)
    }.enabledWhen {
        PuzzleObject.shared.bookmark != nil
    }
    
    MenuSeparator()
    
    TextMenuItem(title: "Page Setup...", action: .pageSetup).enabled(false)
    TextMenuItem(title: "Print", action: .print).enabled(false)
}
