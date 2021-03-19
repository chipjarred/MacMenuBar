import Foundation
import MacMenuBar

// -------------------------------------
let editMenu = StandardMenu(title: "Edit")
{
    TextMenuItem(title: "Undo", action: .undo)
    TextMenuItem(title: "Redo", action: .redo)
    
    MenuSeparator()
    
    TextMenuItem(title: "Cut", action: .cut)
    TextMenuItem(title: "Copy", action: .copy)
    TextMenuItem(title: "Paste", action: .paste)
    TextMenuItem(title: "Paste and Match Style", action: .pasteAndMatchStyle)
    TextMenuItem(title: "Delete", action: .delete)
    TextMenuItem(title: "Select All", action: .selectAll)

    MenuSeparator()
    
    StandardMenu(title: "Find")
    {
        TextMenuItem(title: "Find...", action: .find)
        TextMenuItem(title: "Find and Replace...", action: .findAndReplace)
        TextMenuItem(title: "Find Next", action: .findNext)
        TextMenuItem(title: "Find Previous", action: .findPrevious)
        TextMenuItem(
            title: "Use Selection for Find",
            action: .useSelectionForFind
        )
        TextMenuItem(title: "Jump to Selection", action: .jumpToSelection)
    }
    StandardMenu(title: "Spelling and Grammar")
    {
        TextMenuItem(
            title: "Show Spelling and Grammar",
            action: .showSpellingAndGrammar
        )
        TextMenuItem(title: "Check Document Now", action: .checkDocumentNow)
        
        MenuSeparator()

        TextMenuItem(
            title: "Check Spelling While Typing",
            action: .checkSpellingWhileTyping
        ).toggleStateWhenSelected()
        TextMenuItem(
            title: "Check Grammar While Typing",
            action: .checkGrammarWhileTyping
        ).toggleStateWhenSelected()
        TextMenuItem(
            title: "Correct Spelling Automatically",
            action: .correctSpellingAutomatically
        ).toggleStateWhenSelected()
    }
    StandardMenu(title: "Substitutions")
    {
        TextMenuItem(
            title: "Show Substitutions",
            action: .showSpellingAndGrammar
        )
        MenuSeparator()

        TextMenuItem(title: "Smart Copy/Paste", action: .smartCopyPaste)
            .toggleStateWhenSelected()
        TextMenuItem(title: "Smart Quotes", action: .smartQuotes)
            .toggleStateWhenSelected()
        TextMenuItem(title: "Smart Dashes", action: .smartDashes)
            .toggleStateWhenSelected()
        TextMenuItem(title: "Smart Links", action: .smartLinks)
            .toggleStateWhenSelected()
        TextMenuItem(title: "Data Detectors", action: .dataDetectors)
            .toggleStateWhenSelected()
        TextMenuItem(title: "Text Replacement", action: .textReplacement)
            .toggleStateWhenSelected()
        TextMenuItem(title: "Text Completion", action: .textCompletion)
            .toggleStateWhenSelected()
    }
    StandardMenu(title: "Transformation")
    {
        TextMenuItem(title: "Make Upper Case", action: .makeUppercase)
        TextMenuItem(title: "Make Lower Case", action: .makeLowercase)
        TextMenuItem(title: "Capitalize", action: .capitalize)
    }
    StandardMenu(title: "Speech")
    {
        TextMenuItem(title: "Start Speaking", action: .startSpeaking)
        TextMenuItem(title: "Stop Speaking", action: .stopSpeaking)
    }
}
