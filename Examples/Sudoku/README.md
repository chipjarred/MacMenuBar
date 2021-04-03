# MacMenuBar Example Project: Sudoku 

*Note: This example app is a work in progress, but it's finished enough for the purposes of seeing MacMenuBar in use, so I decided not to wait to make it available.*

This project demonstrates how to use MacMenuBar to manage menus in a SwiftUI application, in this case, a sudoku game.  Although I do promise that the puzzles it randomly produces are valid sudoku puzzles, I don't promise that they're especially well designed by sudoku standards, considering that the main point was to demonstrate MacMenuBar in a real application.  That said, it is playable in ways that I think a user would expect, including keyboard navigation in the puzzle as well as mouse. 

Although working with the menu bar is a weak point in SwiftUI for macOS, and MacMenuBar handles that effectively, it's not the only deficiency in SwiftUI on Mac. Keyboard handling is another. To implement keyboard navigation in the puzzle, this project uses some Cocoa-based hacks that work well for a single window application, but wouldn't be appropriate for a multi-window, document-based app.  Those hacks are just for navigation in the views though.  MacMenuBar does an effective job handling the menus, including key equivalents.

This project uses:

- Selector-based menu actions
- Closure-based menu actions
- Dynamically enabled and disabled menu items.
- Dynamically stateful menu items (checked vs. unchecked)
- Dynamically populated menus
- Dynamically renamed menu items

## TODO
- [x] Undo/Redo
- [x] Game save/restore
- [x] Revert from saved
- [x] Edit/Create themes
- [x] Save preferences
- [ ] Puzzle solved view
- [ ] Usage tutorial on first run
- [ ] Keyboard navigation guides
- [ ] Modify Guess/Note View to change when option key is pressed.
- [x] Support option-click for bringing up Note view
- [ ] Support long click for bringing up Guess view.
