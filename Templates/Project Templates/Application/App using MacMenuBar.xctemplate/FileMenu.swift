import SwiftUI
import MacMenuBar

// -------------------------------------
let fileMenu = StandardMenu(title: "File")
{
    TextMenuItem(title: "New", action: .new)
    TextMenuItem(title: "Open...", action: .open)
    StandardMenu(title: "Open Recent...")
    
    MenuSeparator()
    
    TextMenuItem(title: "Close", action: .close)
    TextMenuItem(title: "Save...", action: .save)
    TextMenuItem(title: "Save As...", action: .saveAs)
    TextMenuItem(title: "Revert to Saved", action: .revert)
    
    MenuSeparator()
    
    TextMenuItem(title: "Page Setup...", action: .pageSetup)
    TextMenuItem(title: "Print", action: .print)
}
