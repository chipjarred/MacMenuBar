import Foundation
import MacMenuBar

// -------------------------------------
let windowMenu = StandardMenu(title: "Window")
{
    TextMenuItem(title: "Minimize", action: .minimize)
    TextMenuItem(title: "Zoom", action: .zoom)
    
    MenuSeparator()
    
    TextMenuItem(title: "Bring All to Front", action: .bringAllToFront)
}
