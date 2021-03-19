import Foundation
import MacMenuBar

// -------------------------------------
let formatMenu = StandardMenu(title: "Format")
{
    StandardMenu(title:"Font")
    {
        TextMenuItem(title: "Show Fonts", action: .showFonts)
        TextMenuItem(title: "Bold", action: .bold)
        TextMenuItem(title: "Italic", action: .italic)
        TextMenuItem(title: "Underline", action: .underline)
        
        MenuSeparator()
        
        TextMenuItem(title: "Bigger", action: .enlargeFont)
        TextMenuItem(title: "Smaller", action: .shrinkFont)
        
        MenuSeparator()
        
        StandardMenu(title: "Kern")
        {
            // TODO: SHould these two be check-marked?
            TextMenuItem(title: "Use Default", action: .useStandardKerning)
            TextMenuItem(title: "Use None", action: .turnOffKerning)
            TextMenuItem(title: "Tighten", action: .tightenKerning)
            TextMenuItem(title: "Loosen", action: .loosenKerning)
        }
        StandardMenu(title: "Ligatures")
        {
            // TODO: SHould these three be check-marked?
            TextMenuItem(title: "Use Default", action: .useStandardLigatures)
            TextMenuItem(title: "Use None", action: .turnOffLigatures)
            TextMenuItem(title: "Use All", action: .useAllLigatures)
        }
        StandardMenu(title: "Baseline")
        {
            // TODO: SHould these four be check-marked?
            TextMenuItem(title: "Use Default", action: .useDefaultBaseline)
            TextMenuItem(title: "Superscript", action: .superscript)
            TextMenuItem(title: "Subscript", action: .subscript)
            TextMenuItem(title: "Raise", action: .raiseBaseline)
            TextMenuItem(title: "Lower", action: .lowerBaseline)
        }
        
        MenuSeparator()
        
        TextMenuItem(title: "Show Colors", action: .showColors)
        
        MenuSeparator()
        
        TextMenuItem(title: "Copy Style", action: .copyStyle)
        TextMenuItem(title: "Paste Style", action: .pasteStyle)
    }
    
    StandardMenu(title:"Text")
    {
        TextMenuItem(title: "Align Left", action: .alignLeft)
        TextMenuItem(title: "Center", action: .alignCenter)
        TextMenuItem(title: "Justify", action: .alignJustified)
        TextMenuItem(title: "Align Right", action: .alignRight)

        MenuSeparator()

        StandardMenu(title: "Writing Direction")
        {
            TextMenuItem(title: "Paragraph").enabled(false)
            TextMenuItem(
                title: "Default",
                action: .useNaturalBaseWritingWritingDirection
            ).indented()
            TextMenuItem(
                title: "Left to Right",
                action: .useLeftToRightBaseWritingDirection
            ).indented()
            TextMenuItem(
                title: "Right to Left",
                action: .useRightToLeftBaseWritingDirection
            ).indented()

            MenuSeparator()

            TextMenuItem(title: "Selection").enabled(false)
            TextMenuItem(
                title: "Default",
                action: .makeNaturalBaseWritingDirection
            ).indented()
            TextMenuItem(
                title: "Left to Right",
                action: .makeLeftToRightDirection
            ).indented()
            TextMenuItem(
                title: "Right to Left",
                action: .makeRightToLeftDirection
            ).indented()
        }

        MenuSeparator()

        TextMenuItem(title: "Show Ruler", action: .showRuler)
        TextMenuItem(title: "Copy Ruler", action: .copyRuler)
        TextMenuItem(title: "PasteRuler", action: .pasteRuler)
    }
}
