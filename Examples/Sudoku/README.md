# MacMenuBar Example Project: Sudoku 

*Note: This example app is a work in progress, but it's finished enough for the purposes of seeing MacMenuBar in use, so I decided not to wait to make it available.*

This project is demonstrates how to use MacMenuBar to manage menus in a SwiftUI application, in this case, a sudoku game.  Although I do promise that the puzzles it randomly produces are valid sudoku puzzles, I don't promise that they're especially well designed, considering that the main point was to demonstrate MacMenuBar in a real application.  That said, it is playable in ways that I think a user would expect, including keyboard navigation in the puzzle as well as mouse. 

The keyboard handling is another weak point in SwiftUI for Mac apps, to implement the keyboard navigation this project uses some Cocoa-based keyboard hacks that work well for a single window application, but wouldn't be appropriate for a multi-window, document-based app.  Those hacks aren't needed for the menu handling, as MacMenuBar handles that part effectively.

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
- [ ] Edit/Create themes
- [x] Save preferences
- [ ] Puzzle solved view
- [ ] Usage tutorial on first run
- [ ] Keyboard navigation guides
- [ ] Modify Guess/Note View to change when option key is pressed.
- [x] Support option-click for bringing up Note view
- [ ] Support long click for bringing up Guess view.
