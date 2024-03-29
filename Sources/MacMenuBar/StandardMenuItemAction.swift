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

import Cocoa

public enum StandardMenuItemAction
{
    // Non-menus
    case cancel
    
    // Application Menu
    case about
    case hide
    case hideOthers
    case showAll
    case quit
    
    // File Menu
    case new
    case open
    case close
    case save
    case saveAs
    case revert
    case pageSetup
    case print
    
    // Edit Menu
    case undo
    case redo
    case cut
    case copy
    case paste
    case pasteAndMatchStyle
    case delete
    case selectAll
    
    // Find Menu
    case find
    case findAndReplace
    case findNext
    case findPrevious
    case useSelectionForFind
    case jumpToSelection
    
    // Spelling and Grammar Menu
    case showSpellingAndGrammar
    case checkDocumentNow
    case checkSpellingWhileTyping
    case checkGrammarWhileTyping
    case correctSpellingAutomatically
    
    // Substitutions Menu
    case showSubstutions
    case smartCopyPaste
    case smartQuotes
    case smartDashes
    case smartLinks
    case dataDetectors
    case textReplacement
    case textCompletion
    
    // Transformation Menu
    case makeUppercase
    case makeLowercase
    case capitalize
    
    // Speech Menu
    case startSpeaking
    case stopSpeaking
    
    // Font Menu
    case showFonts
    case bold
    case italic
    case underline
    case enlargeFont
    case shrinkFont
    case showColors
    case copyStyle
    case pasteStyle
    
    // Kern Menu
    case useStandardKerning
    case turnOffKerning
    case tightenKerning
    case loosenKerning
    
    // Ligature Menu
    case useStandardLigatures
    case turnOffLigatures
    case useAllLigatures
    
    // Baseline Menu
    case useDefaultBaseline
    case superscript
    case `subscript`
    case raiseBaseline
    case lowerBaseline
    
    // Text Menu
    case alignLeft
    case alignCenter
    case alignJustified
    case alignRight
    case showRuler
    case copyRuler
    case pasteRuler
    
    // Writing Direction Menu
    case useNaturalBaseWritingWritingDirection
    case useLeftToRightBaseWritingDirection
    case useRightToLeftBaseWritingDirection
    case makeNaturalBaseWritingDirection
    case makeLeftToRightDirection
    case makeRightToLeftDirection
    
    // View Menu
    case showToolbar
    case customizeToolbar
    case showSidebar
    case enterFullScreen
    case exitFullScreen

    // Window Menu
    case minimize
    case zoom
    case bringAllToFront
    
    public var selector: Selector { selectorAndKeyEquivalent.action }
    public var keyEquivalent: KeyEquivalent {
        selectorAndKeyEquivalent.keyEquivalent
    }

    public var selectorAndKeyEquivalent:
        (action: Selector, keyEquivalent: KeyEquivalent)
    {
        switch self
        {
            // Non-menus
            case .cancel:
                return (
                    #selector(NSResponder.cancelOperation(_:)),
                    .command + "."
                )

            // Application Menu
            case .about:
                return (
                    #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
                    .none
                )
            case .hide:
                return (
                    #selector(NSApplication.hide),
                    .command + "h"
                )
            case .hideOthers:
                return (
                    #selector(NSApplication.hideOtherApplications),
                    .command + .option + "h"
                )
            case .showAll:
                return (
                    #selector(NSApplication.unhideAllApplications),
                    .none
                )
            case .quit:
                return (#selector(NSApplication.terminate(_:)), .command + "q")

            // File Menu
            case .new:
                return (
                    #selector(NSDocumentController.newDocument(_:)),
                    .command + "n"
                )
            case .open:
                return (
                    #selector(NSDocumentController.openDocument(_:)),
                    .command + "o"
                )
            case .close:
                return (#selector(NSWindow.performClose(_:)), .command + "w")
            case .save:
                return (#selector(NSDocument.save(_:)), .command + "s")
            case .saveAs:
                return (#selector(NSDocument.saveTo(_:)), .command + "S")
            case .revert:
                return (#selector(NSDocument.revertToSaved(_:)), .command + "r")
            case .pageSetup:
                return (#selector(NSDocument.runPageLayout(_:)), .command + "P")
            case .print:
                return (#selector(NSDocument.printDocument(_:)), .command + "p")
                
            // Edit Menu
            case .undo:
                return (#selector(UndoManager.undo), .command + "z")
            case .redo:
                return (#selector(UndoManager.redo), .command + "Z")
            case .cut:
                return (#selector(NSText.cut(_:)), .command + "x")
            case .copy:
                return (#selector(NSText.copy(_:)), .command + "c")
            case .paste:
                return (#selector(NSText.paste(_:)), .command + "v")
            case .pasteAndMatchStyle:
                return (
                    #selector(NSTextView.pasteAsPlainText(_:)),
                    .command + .option + "V"
                )
            case .delete:
                return (#selector(NSText.delete(_:)), .none)
            case .selectAll:
                return (#selector(NSText.selectAll(_:)), .command + "a")
                
            // Find menu
            case .find:
                return (
                    #selector(NSTextView.performFindPanelAction(_:)),
                    .command + "f"
                )
            case .findAndReplace:
                return (
                    #selector(NSTextView.performFindPanelAction(_:)),
                    .command + .option + "f"
                )
            case .findNext:
                return (
                    #selector(NSTextView.performFindPanelAction(_:)),
                    .command + "g"
                )
            case .findPrevious:
                return (
                    #selector(NSTextView.performFindPanelAction(_:)),
                    .command + .shift + "g"
                )
            case .useSelectionForFind:
                return (
                    #selector(NSTextView.performFindPanelAction(_:)),
                    .command + "e"
                )
            case .jumpToSelection:
                return (
                    #selector(NSTextView.centerSelectionInVisibleArea(_:)),
                    .command + "j"
                )
                
            // Spelling and Grammar Menu
            case .showSpellingAndGrammar:
                return (
                    #selector(NSTextView.showGuessPanel(_:)),
                    .command + ":"
                )
            case .checkDocumentNow:
                return (
                    #selector(NSTextView.checkSpelling(_:)),
                    .command + ";"
                )
            case .checkSpellingWhileTyping:
                return (
                    #selector(NSTextView.toggleContinuousSpellChecking(_:)),
                    .none
                )
            case .checkGrammarWhileTyping:
                return (
                    #selector(NSTextView.toggleGrammarChecking(_:)),
                    .none
                )
            case .correctSpellingAutomatically:
                return (
                    #selector(NSTextView.toggleAutomaticSpellingCorrection(_:)),
                    .none
                )
                
            // Substitutions Menu
            case .showSubstutions:
                return (
                    #selector(NSTextView.orderFrontSubstitutionsPanel(_:)),
                    .none
                )
            case .smartCopyPaste:
                return (
                    #selector(NSTextView.toggleSmartInsertDelete(_:)),
                    .none
                )
            case .smartQuotes:
                return (
                    #selector(NSTextView.toggleAutomaticQuoteSubstitution(_:)),
                    .none
                )
            case .smartDashes:
                return (
                    #selector(NSTextView.toggleAutomaticDashSubstitution(_:)),
                    .none
                )
            case .smartLinks:
                return (
                    #selector(NSTextView.toggleAutomaticLinkDetection(_:)),
                    .none
                )
            case .dataDetectors:
                return (
                    #selector(NSTextView.toggleAutomaticDataDetection(_:)),
                    .none
                )
            case .textReplacement:
                return (
                    #selector(NSTextView.toggleAutomaticTextReplacement(_:)),
                    .none
                )
                
            case .textCompletion:
                return (
                    textCompletionActionSelector,
                    .none
                )

            // Transformation Menu
            case .makeUppercase:
                return (
                    #selector(NSTextView.uppercaseWord(_:)),
                    .none
                )
            case .makeLowercase:
                return (
                    #selector(NSTextView.lowercaseWord(_:)),
                    .none
                )
            case .capitalize:
                return (
                    #selector(NSTextView.capitalizeWord(_:)),
                    .none
                )
                
            // Speech Menu
            case .startSpeaking:
                return (
                    #selector(NSTextView.startSpeaking(_:)),
                    .none
                )
            case .stopSpeaking:
                return (
                    #selector(NSTextView.stopSpeaking(_:)),
                    .none
                )
                
            // Font Menu
            case .showFonts:
                return (
                    #selector(NSFontManager.orderFrontFontPanel(_:)),
                    .command + "t"
                )
            case .bold:
                return (
                    #selector(NSFontManager.addFontTrait(_:)),
                    .command + "b"
                )
            case .italic:
                return (
                    #selector(NSFontManager.addFontTrait(_:)),
                    .command + "i"
                )
            case .underline:
                return (
                    #selector(NSText.underline(_:)),
                    .command + "u"
                )
            case .enlargeFont:
                return (
                    #selector(NSFontManager.modifyFont(_:)),
                    .command + "+"
                )
            case .shrinkFont:
                return (
                    #selector(NSFontManager.modifyFont(_:)),
                    .command + "-"
                )
            case .showColors:
                return (
                    #selector(NSApplication.orderFrontColorPanel(_:)),
                    .command + "C"
                )
            case .copyStyle:
                return (
                    #selector(NSText.copyFont(_:)),
                    .command + .option + "c"
                )
            case .pasteStyle:
                return (
                    #selector(NSText.pasteFont(_:)),
                    .command + .option + "v"
                )
                
            // Kern Menu
            case .useStandardKerning:
                return (
                    #selector(NSTextView.useStandardKerning(_:)),
                    .none
                )
            case .turnOffKerning:
                return (
                    #selector(NSTextView.turnOffKerning(_:)),
                    .none
                )
            case .tightenKerning:
                return (
                    #selector(NSTextView.tightenKerning(_:)),
                    .none
                )
            case .loosenKerning:
                return (
                    #selector(NSTextView.loosenKerning(_:)),
                    .none
                )
                
            // Ligature Menu
            case .useStandardLigatures:
                return (
                    #selector(NSTextView.useStandardLigatures(_:)),
                    .none
                )
            case .turnOffLigatures:
                return (
                    #selector(NSTextView.turnOffLigatures(_:)),
                    .none
                )
            case .useAllLigatures:
                return (
                    #selector(NSTextView.useAllLigatures(_:)),
                    .none
                )
                
            // Baseline Menu
            case .useDefaultBaseline:
                return (
                    #selector(NSText.unscript(_:)),
                    .none
                )
            case .superscript:
                return (
                    #selector(NSText.superscript(_:)),
                    .none
                )
            case .`subscript`:
                return (
                    #selector(NSText.subscript(_:)),
                    .none
                )
            case .raiseBaseline:
                return (
                    #selector(NSTextView.raiseBaseline(_:)),
                    .none
                )
            case .lowerBaseline:
                return (
                    #selector(NSTextView.lowerBaseline(_:)),
                    .none
                )
                
            // Text Menu
            case .alignLeft:
                return (
                    #selector(NSTextView.alignLeft(_:)),
                    .command + "{"
                )
            case .alignCenter:
                return (
                    #selector(NSTextView.alignCenter(_:)),
                    .command + "|"
                )
            case .alignJustified:
                return (
                    #selector(NSTextView.alignJustified(_:)),
                    .none
                )
            case .alignRight:
                return (
                    #selector(NSTextView.alignRight),
                    .command + "}"
                )
            case .showRuler:
                return (
                    #selector(NSTextView.toggleRuler(_:)),
                    .none
                )
            case .copyRuler:
                return (
                    #selector(NSTextView.copyRuler(_:)),
                    .control + .command + "c"
                )
            case .pasteRuler:
                return (
                    #selector(NSTextView.pasteRuler(_:)),
                    .control + .command + "v"
                )
                
            // Writing Direction Menu
            case .useNaturalBaseWritingWritingDirection:
                return (
                    #selector(NSTextView.makeBaseWritingDirectionNatural(_:)),
                    .none
                )
            case .useLeftToRightBaseWritingDirection:
                return (
                    #selector(
                        NSTextView.makeBaseWritingDirectionLeftToRight(_:)
                    ),
                    .none
                )
            case .useRightToLeftBaseWritingDirection:
                return (
                    #selector(
                        NSTextView.makeBaseWritingDirectionLeftToRight(_:)
                    ),
                    .none
                )
            case .makeNaturalBaseWritingDirection:
                return (
                    #selector(NSTextView.makeTextWritingDirectionNatural(_:)),
                    .none
                )
            case .makeLeftToRightDirection:
                return (
                    #selector(
                        NSTextView.makeTextWritingDirectionLeftToRight(_:)
                    ),
                    .none
                )
            case .makeRightToLeftDirection:
                return (
                    #selector(
                        NSTextView.makeTextWritingDirectionRightToLeft(_:)
                    ),
                    .none
                )
                
            // View Menu
            case .showToolbar:
                return (
                    #selector(NSWindow.toggleToolbarShown(_:)),
                    .command + .option + "t"
                )
            case .customizeToolbar:
                return (
                    #selector(NSWindow.runToolbarCustomizationPalette(_:)),
                    .none
                )
            case .showSidebar:
                return (
                    #selector(NSSplitViewController.toggleSidebar(_:)),
                    .control + .command + "s"
                )
            case .enterFullScreen:
                return (
                    #selector(NSWindow.toggleFullScreen(_:)),
                    .control + .command + "f"
                )
            case .exitFullScreen:
                return (
                    #selector(NSWindow.toggleFullScreen(_:)),
                    .escape
                )

            // Window Menu
            case .minimize:
                return (
                    #selector(NSWindow.performMiniaturize(_:)),
                    .command + "m"
                )
            case .zoom:
                return (
                    #selector(NSWindow.performZoom(_:)),
                    .none
                )
            case .bringAllToFront:
                return (
                    #selector(NSApplication.arrangeInFront(_:)),
                    .none
                )

        }
    }
    
    fileprivate var textCompletionActionSelector: Selector
    {
        /*
         Prior to macOS 10.12.2, text completion in macOS was not supplied by
         AppKit, so prior to that, we supply selector to a no-op method that
         shouldn't be implemented by anything in the responder chain.
         Consequently, the corresponding menu item will be disabled by AppKit.
         */
        if #available(OSX 10.12.2, *) {
            return #selector(NSTextView.toggleAutomaticTextCompletion(_:))
        }
        else { return #selector(BagOfSelectors.macMenuBar_DoNothing__(_:)) }
    }
}

/**
 Just an `NSObject` subclass for the sole purpose of declaring methods to take selectors from
 */
@objc
fileprivate class BagOfSelectors: NSObject {
    @objc func macMenuBar_DoNothing__(_ sender: Any?) { }
}
