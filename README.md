# MacMenuBar

Are you writing a macOS application using SwiftUI and wish you could work with the menu bar (aka "main menu") like you do your SwiftUI views?  Now you can!

Let's dive directly into how to use it. 

## Configure Your Project for MacMenuBar

Since Xcode's starter project template for a macOS SwiftUI app isn't set up for `MacMenuBar` there are few things you have to change to make it ready.

1. Add this package as a dependency in your app. In Xcode select `Swift Packages` from the `File` menu, then `Add Pacakge Dependency`.  Then fill-in the URL for this package.

2. Tell Xcode your app depends on the `MacMenuBar` library.  Click on your project's icon in the `Project Navigator` (the left side bar where files and folders  are shown).  Select your application's target, in the section labeled `Frameworks, Librarys, and Embedded Content` click on the `+` sign and then select the `MacMenuBar` library from the list.  Click `Add`.

3. Remove  the `Main.storyboard` file.  Just like you don't use a Storyboard for your SwiftUI `View` types, you don't use them for `MacMenuBar` either.  Just delete it (or uncheck it as belonging to the application target in the `File Inspector` side-bar on the right)

4. Add `main.swift`.  With `Main.storyboard` gone, `NSApplication` won't' work automagically, so you have to add a `main.swift` to provide a working entry point for your app.  It should look like this.

```swift
import Cocoa
let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
```
5.  Remove the `@NSApplicationMain` attribute from `AppDelegate` in  `AppDelegate.swift`.  
```swift
@NSApplicationMain // <- REMOVE THIS
class AppDelegate: NSObject, NSApplicationDelegate
```

6. Import `MacMenuBar` in `AppDelelgate.swift`:

```swift
import Cocoa
import SwiftUI
import MacMenuBar // <-- ADD THIS
```

7. Test the setup by building and running the app.  You no longer have a menu bar in the app, so you'll need to kill it using Stop button in Xcode.

## Creating a Simple Menu Bar

Now we'll create a minimalist menu bar with just the application menu and the usual `File` menu to get started.

Create a new file called `MenuBar.swift` with the following code

```swift
#import MacMenuBar

struct MainMenuBar: MenuBar
{
    public var body: StandardMenuBar
    {
        StandardMenuBar
        {
            StandardMenu(title: "$(AppName)")
            {
                TextMenuItem(title: "About $(AppName)", action: .about)
                                
                MenuSeparator()
                
                TextMenuItem(title: "Quit $(AppName)", action: .quit)
            }
            
            StandardMenu(title: "File")
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
        }
    }
}
```
This kind of looks like how you write your SwiftUI `View` code doesn't it?  We just need to tell the `AppDelegate` to use it.  So at the end of `AppDelegate.applicationDidFinishLaunching()`  add `setMenuBar(to: MainMenuBar())`

```swift
func applicationDidFinishLaunching(_ aNotification: Notification)
{
    // Create the SwiftUI view that provides the window contents.
    let contentView = MainContentView()

    // Create the window and set the content view.
    window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
        styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
        backing: .buffered,
        defer: false
    )
    window.isReleasedWhenClosed = false
    window.center()
    window.setFrameAutosaveName("Main Window")
    window.contentView = NSHostingView(rootView: contentView)
    window.makeKeyAndOrderFront(nil)
        
    setMenuBar(to: MainMenuBar()) // <- ADD THIS
}
```

Now your shiny new, albeit minimalist, menu bar is set up.  Run the application to see it work.  Of course, the only thing you can do from it right now is to quit, and display the about box, but that's all you coud do with the one Apple provided in the `Main.storyboard` file we deleted.  Before we start adding functionality let's take a look at a few things, so go back to `MenuBar.swift`.

You'll see that `MainMenuBar.body` returns a `StandardMenuBar`.  Think of it as sort of analogous to `HStack`, but for menus.  

Our actual menus in the menu bar are declared as `StandardMenu`.   These correspond to the main items you see in the menu bar when you haven't clicked on anything.  You provide each one with the `String` to use for it's title, however, that text is a bit smarter than your average `String`, because it actually does two things for you automatically. 

1. It looks up a localized version of the `String` you specify as the time.  It looks in the `Menus.strings` file in your app''s bundle (or one of the appropriate localization subdirectory).  If it finds one, it uses the localized string.  If not, it uses the string as-is.

2. It does string substituation within the string returned from step 1.   The title string for our application menu contains `"$(AppName)"` .  This is automatically replaced by your program's name. The substitution strings take the form `$(SomeName)`  `MacMenuBar` looks for a value to substitute for whatever is in the parentheses.   It first checks to see if it's a pre-defined symbol, which `AppName` is, and if not it looks for an variable with a matching name in your application's process environment (`ProcessInfo.processInfo.environment`).

The titles for all menus and menu items in `MacMenuBar` work this way.  This makes localization easy.  More substitution options are planned as well.

Within the top-level `StandardMenu` instances, we have two kinds of menu items: `TextMenuItem` and `MenuSeparator`.  

`TextMenuItem` is your basic, most commonly used menu item.  You associate give it a title and an action.  The code above uses standard menu actions, but as you'll see later, you can define your own.  For a complete list of the standard ones, see `StandardMenuItemAction.swift`. These standard menu item actions use the usual responder chain you're familiar with from ordinary Cocoa apps, and use the usual key equivalents that Mac users expect.

`MenuItemSeparator` gives the familiar dividing linen used to separate related groups of menu items within a menu.

Although we haven't done it so far, you can also nest one or more `StandardMenu` instances inside of another `StandardMenu`, creating submenus.   

## Custom Menu Actions

The easiest way to define a custom action is with a closure. Let's say you have a `showLog()` function that displays a log window, and you want to add a `Debug` menu an item to show the log.  At the end of `MainMenuBar.body` you can your conditionally-compiled `Debug` menu:

```swift
#import MacMenuBar

struct MainMenuBar: MenuBar
{
    public var body: StandardMenuBar
    {
        StandardMenuBar
        {
            StandardMenu(title: "$(AppName)")
            {
                TextMenuItem(title: "About $(AppName)", action: .about)
                                
                MenuSeparator()
                
                TextMenuItem(title: "Quit $(AppName)", action: .quit)
            }
            
            StandardMenu(title: "File")
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
        }
        
        // >>>>>>>> ADDED THE FOLLOWING BIT <<<<<<<<<<
        #if DEBUG
        StandardMenu(title: "Debug")
        {
            TextMenuItem(title: "Show Log", keyEquivalent: .command + .option + "L") { _ in
                showLog()
            }
        }
        #endif
    }
}
```

As you can see, this ads a new menu called `Debug` to the menu bar.  It contains a menu item called `Show Log`, but what's different about our previous `TextMenuItem` examples, is that now we're specifying both a key equivalent for the menu item, and an action closure that is called when the menu item is selected.    If you don't want a key equivalent for your menu item, you can specify `.none` or just omit it altogether.
