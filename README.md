# MacMenuBar

Are you writing a macOS application using SwiftUI? Do wish you could programmatically create and work with the menu bar (aka "main menu") like you do your SwiftUI views? 

SwiftUI makes creating views programmatically simple, but it's focus on iOS shows when you use it to create a macOS app. Menu handling is a big part of that defiiciency.  No doubt, Apple will improve that over time, but for now you're stuck with the same `AppKit` menu API as in a normal Cocoa app, only it's less obvious how to  interact with it from SwiftUI.  Want to disable a menu, or change it's title?  You have to hunt it down in `NSWindow.shared.mainMenu`.  Programmatically creating your main menu with `AppKit` at least gives you a chance to store references to your menus for easy access, but it's a headache too. 

I wanted to build my app's menu the same declarative way I build SwiftUI views.  I wanted it to dynamically update and respond in same sort of way SwiftUI views do.   Those are the problems `MacMenuBar` aims to solve.

Let's dive directly into how to use it. 

## Configure Your Project for MacMenuBar

Since Xcode's starter project template for a macOS SwiftUI app isn't set up for `MacMenuBar` there are few things you have to change to make it ready.

1. Add `MacMenuBar` as a Swift Package Dependency in your app. In Xcode select `Swift Packages` from the `File` menu, then `Add Package Dependency`.  Then fill-in the URL for this package: [https://github.com/chipjarred/MacMenuBar.git](https://github.com/chipjarred/MacMenuBar.git)

2. Remove  the `Main.storyboard` file.  Just like you don't use a Storyboard for your SwiftUI `View` types, you don't use them for `MacMenuBar` either.  Just delete it (or uncheck it as belonging to the application target in the `File Inspector` side-bar on the right). 

3. Change the `Main Interface` target setting. 
    1. Click on the project in the Project Navigator (side bar to the left that shows files and folder)
    2. Select your application target
    3. Select the "General" tab at the top, then in the "Deployment Info" section, clear the "Main Interface" field.

3. Add `main.swift`.  With `Main.storyboard` gone, `NSApplication` won't work automagically, so you have to add a `main.swift` to provide a working entry point for your app.  It should look like this.

```swift
import Cocoa
let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
```
4.  Remove the `@NSApplicationMain` attribute from `AppDelegate` in  `AppDelegate.swift`.  
```swift
@NSApplicationMain // <- REMOVE THIS
class AppDelegate: NSObject, NSApplicationDelegate
```

5. Import `MacMenuBar` in `AppDelelgate.swift`:

```swift
import Cocoa
import SwiftUI
import MacMenuBar // <-- ADD THIS
```

6. Test the setup by building and running the app.  You no longer have a menu bar in the app, so *you'll need to kill it using Stop button in Xcode.*

## Creating a Simple Menu Bar

Now we'll create a minimalist menu bar with just the application menu and the usual `File` menu to get started.

Create a new file called `MenuBar.swift` with the following code

```swift
import MacMenuBar

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
This kind of looks like how you write your SwiftUI `View` code, doesn't it?  

Now we just need to tell the `AppDelegate` to use it.  So at the end of `AppDelegate.applicationDidFinishLaunching()`  add `setMenuBar(to: MainMenuBar())`

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

Now your shiny new, albeit bare bones menu bar is set up.  Run the application to see it work.  Of course, the only thing you can do from it right now is to quit, and display the About box, but in a brand new project that's all you could really do with the one Apple provided in the `Main.storyboard` file we deleted.  

### What have we done?
Before we start adding functionality let's take a closer look at a few things, so go back to `MenuBar.swift`.

You'll see that `MainMenuBar.body` returns a `StandardMenuBar`.  Think of it as sort of analogous to `HStack`, but for menus and we don't nest it inside other menus.  It's strictly a top-level thing representing the menu bar.  

Our actual menus in the menu bar are declared as `StandardMenu`.   These correspond to the main items you see in the menu bar when you haven't clicked on anything.  You provide each one with the `String` to use for its title, however, that text is a bit smarter than your average `String`, because it actually does two things for you automatically. 

1. It looks up a localized version of the `String` you specify as the title.  It uses the `Menus.strings` file in your app's bundle (or one of the appropriate localization subdirectories), if you include it.  If it finds one, it uses the localized string from it.  If not, it uses the string as-is for the next step.

2. It does string substituation within the string returned from step 1, whether it's the localized string or not.   The title string for our application menu contains `"$(AppName)"` .  This is automatically replaced by your program's name. The substitution strings take the form `$(SomeName)`.  `MacMenuBar` looks for a value to substitute for whatever is in the parentheses.   It first checks to see if it's a pre-defined symbol, which `AppName` is, and if not it looks for a variable with a matching name in your application's process environment (`ProcessInfo.processInfo.environment`).  So `"$(PATH)"`  evaluates to whatever the `PATH` variable is set to in your app's environment.  If no such variable is found, then it evaluates to itself, as-is. 

The titles for all menus and menu items in `MacMenuBar` work this way.  This makes localization easy.  More substitution options are planned as well.

Within the top-level `StandardMenu` instances we have two kinds of menu items: `TextMenuItem` and `MenuSeparator`.  

`TextMenuItem` is your basic, most commonly used menu item.  You give it a title and an action.  The code above uses standard menu actions, but as you'll see later, you can define your own.  For a complete list of the standard ones, see `StandardMenuItemAction.swift`. These standard menu item actions use the usual responder chain you're familiar with from ordinary Cocoa apps, and the usual key equivalents that Mac users expect.

`MenuItemSeparator` gives the familiar dividing line that separates groups of related menu items within a menu.

Although we haven't done it so far, you can also nest one or more `StandardMenu` instances inside another `StandardMenu`, creating submenus.   

Finally the change we made to `AppDelegate.applicationDidFinishLaunching` by calling `setMenuBar(to: MainMenuBar())` is the line that actuallys sets the application's main menu to our `MainMenuBar`.  SwiftUI has to do something similar a few lines up in the line, `let contentView = MainContentView()`.  It's just that the project template already provided that line, so you don't have to write it yourself.

## Custom Menu Actions

It's great that we have a menu bar now, and that we've created it in a simple delcarative way, but it doesn't do much.  Let's start to fix that.  You do that by creating a menu item with an *action* associated with it.

The easiest way to define a custom action is with a closure. Let's say you have a `showLog()` function that displays a log window, and you want to add a `Debug` menu item to show the log.  At the end of `MainMenuBar.body` you can add your conditionally-compiled `Debug` menu:

```swift
import MacMenuBar

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
            TextMenuItem(title: "Show Log", keyEquivalent: .command + .option + "l") { _ in
                showLog()
            }
        }
        #endif
    }
}
```

As you can see, this adds a new menu called `Debug` to the menu bar.  It contains a menu item called `Show Log`, but what's different from our previous `TextMenuItem` examples is that now we're specifying both a key equivalent for the menu item, and an action closure that is called when the menu item is selected.   

Note that when specifying the key equivalent, we used a lowercase "L".  Using uppercase would imply that the shift key would also need to be pressed.   `"L"` and `.shift + "l"` are equivalent in this context.  If at least one of  `.command`, `.option` or `.control` is not specified, `.command` is implied, so you if you use just `"l"` for your key equivalent, it will be treated as `.command + "l"`.   Also note  that we don't need to muck about with `NSEvent` modifier flags.  We can specify the modifiers by naming them and adding them to the base key.

The `StandardMenuItemAction` examples we delcared in our application and `File` menus already have the standard key equivalents impliicitly associated with them, so they don't need to be specified.   

If you don't want a key equivalent for your closure menu item, you can specify `.none`.

Of course, you can also specify an action using an arbitrary `Selector`.

## Dynamically Enabling/Disabling Menu Items

A lot of menu item updating, especially enabling and disabling them, happens automatically via Cocoa's [Responder Chain](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/EventArchitecture/EventArchitecture.html#//apple_ref/doc/uid/10000060i-CH3-SW2), but that works based whether some object in the responder chain responds to the Objective-C selector associated with a given menu.  That's the way Cocoa apps work in Swift too, and it applies to `Selector`-based menus actions in `MacMenuBar`, if the `AppKit` objects underlying your SwiftUI views respond to the appropriate selectors. On the other hand, closure-based menu actions in `MacMenuBar`, such as the one we wrote in the previous example, require more explicit handling.

Suppose we just want to disable the "Show Log" menu item once the log is shown. We can specify that behavior using the `afterAction` method, which takes the menu item itself as its parameter:

```swift
            #if DEBUG
            StandardMenu(title: "Debug")
            {
                TextMenuItem(title: "Show Log", keyEquivalent: .command + .option + "l") { _ in
                    showLog()
                }
                .afterAction { $0.canBeEnabled = false } // <- ADDED THIS
            }
            #endif
```
As its name suggests, `.afterAction` is called after the menu item calls its action closure.   There is also a `.beforeAction` method that works the same way, except that it is called immediately before the action closure is called.

Now when you select "Show Log" from the "Debug" menu, that item will become disabled.  Of course, that's not actually what we want, because it will remain disabled even after you close the log window.  We'd prefer for it to be enabled or disabled based on whether the log window is currently visible.  Instead of `.afterAction` we can use `.enabledWhen`:

```swift
            #if DEBUG
            StandardMenu(title: "Debug")
            {
                TextMenuItem(title: "Show Log", keyEquivalent: .command + .option + "l") { _ in
                    showLog()
                }
                .enabledWhen { !logWindow.isVisible } // <- CHANGED THIS
            }
            #endif
```

`.enabledWhen` is called whenever the item's parent menu is opened to determine whether or not that item is enabled.  The "Show Log" menu item will now be disabled whenever the log window is visible, and enabled whenever it's hidden.

The actual process `MacMenuBar` uses for determining whether the menu should be enabled or disabled is:

1. If the menu item does *not* have an associated action, then it is *disabled*.  If it does have an action, validation proceeds to the next step.

2. If the menu item's action is a `Selector`-based action *and* no object in the responder chain responds to that selector, then the menu item is *disabled*.  If some responder in the chain does respond to that selector, or if the action is a closure action, validation proceeds to the next step.

3. If the menu item's `.canBeEnabled`  property is `false`, then menu item is *disabled*.  If it's `true`, which is the default, the validation process continues to the next step.

4. If `.enabledWhen` has *not* been used to set a validation closure for the item, then the item is *enabled*.   If it does have a validation closure, validation proceeds to the next step.

5. The validation closure set with `.enabledWhen` is used to determine whether or not the menu item is enabled.  If the closure returns `true`, it is *enabled*.  If it returns `false`, it is *disabled*.

The above list extends the logic of Cocoa's built-in menu-enabling rules.  Of special note is that if both `.canBeEnabled` and `.enabledWhen`  are used and `.canBeEnabled` is `false`, that overrules the closure for `.enabledWhen`. In most cases, it makes sense to use one or the other, but not both, but it does give you a way to tell `MacMenuBar` to unconditionally disable a menu item, even if it is using `.enableWhen`.
    
## Dynamically Updating Menu Item Names

In its current state, our "Show Log" menu item is certainly usable now, but is it what Mac users really expect?  Maybe it would be better to change the menu item to "Hide Log"  when the log is visible, and back to "Show Log"  when it's not.  That way we can toggle the log window's visible state with a key equivalent.   We can do that by modifying our action closure to either show or hide the log window based on its current visibility, and use the `.updatingTitleWith` method to specify a closure for updating the title:

```swift
            #if DEBUG
            StandardMenu(title: "Debug")
            {
                TextMenuItem(title: "Show Log", keyEquivalent: .command + .option + "l") { _ in
                    if logWindow.isVisible {
                        hideLog()
                    }
                    else { showLog() }
                }
                .updatingTitleWith { logWindow.isVisible ? "Hide Log" : "Show Log" }
            }
            #endif
```
The closure you pass to `.updatingTitleWith` is called when the user opens the item's parent menu before determining the item's enabled state.  This gives you a chance to update the item's appearance by changing the title.
