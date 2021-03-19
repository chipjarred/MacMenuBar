import Cocoa
import MacMenuBar

// -------------------------------------
let viewMenu = StandardMenu(title: "View")
{
    TextMenuItem(title: "Show Toolbar", action: .showToolbar)
    TextMenuItem(title: "Customize Toolbar...", action: .customizeToolbar)
    
    MenuSeparator()
    
    TextMenuItem(title: "Show Sidebar", action: .showSidebar)
    
    // Toggle full screen is automatically added by macOS
    // TODO: Either prevent automatic full screen addition, or attach
    // keyEquivalent to the automatically added menu
    TextMenuItem(title: "Enter Full Screen", action: .enterFullScreen)
        .afterAction
        { menuItem in
            if AppDelegate.isFullScreen
            {
                menuItem.title = "Exit Full Screen"
                KeyEquivalent.escape.set(in: menuItem)
            }
            else
            {
                menuItem.title = "Enter Full Screen"
                (.command + .control + "f").set(in: menuItem)
            }
        }
}
