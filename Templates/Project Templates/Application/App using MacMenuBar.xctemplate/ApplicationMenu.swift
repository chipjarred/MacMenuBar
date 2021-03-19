import SwiftUI
import MacMenuBar

// -------------------------------------
let applicationMenu = StandardMenu(title: "$(AppName)")
{
    TextMenuItem(title: "About $(AppName)", action: .about)
    
    MenuSeparator()
    
    TextMenuItem(title: "Preferences...", keyEquivalent: .command + ",")
    { _ in }
    
    MenuSeparator()
    
    StandardMenu(title: "Services")
    
    MenuSeparator()
    
    TextMenuItem(title: "Hide $(AppName)", action: .hide)
    TextMenuItem(title: "Hide Others", action: .hideOthers)
    TextMenuItem(title: "ShowAll", action: .showAll)
    
    MenuSeparator()
    
    TextMenuItem(title: "Quit $(AppName)", action: .quit)
}
