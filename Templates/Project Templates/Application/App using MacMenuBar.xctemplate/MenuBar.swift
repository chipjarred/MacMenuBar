import SwiftUI
import MacMenuBar

// -------------------------------------
struct MainMenuBar: MenuBar
{
    public var body: StandardMenuBar
    {
        StandardMenuBar
        {
            applicationMenu
            fileMenu
            editMenu
            formatMenu
            viewMenu
            windowMenu
            
            #if DEBUG
            debugMenu
            #endif
        }
    }
}
