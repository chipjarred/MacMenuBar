import Cocoa
import MacMenuBar

// -------------------------------------
let viewMenu = StandardMenu(title: "View")
{
    TextMenuItem(title: "Show Toolbar", action: .showToolbar)
    TextMenuItem(title: "Customize Toolbar...", action: .customizeToolbar)
    
    MenuSeparator()
    
    TextMenuItem(title: "Show Sidebar", action: .showSidebar)
    
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
.refuseAutoinjectedMenuItems()
