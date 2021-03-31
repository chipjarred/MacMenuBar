# MacMenuBar

MacMenuBar is a Swift Package for creating and working with macOS's main menu in SwiftUI apps without a Storyboard. It let's you use the same declarative style you use for your SwiftUI views to create your menus.

Let's dive directly into how to use it. 

## Creating a MacMenuBar-based Project.

To use MacMenuBar you will need to create an Xcode project configured to use it.  The easiest way to do that is by installing the Xcode project templates from this repo using the command line:

```bash
git clone https://github.com/chipjarred/MacMenuBar.git
cd MacMenuBar/Templates
./install.bash
```

Once the templates are installed, when you create a new macOS app in Xcode, a template named "App using MacMenuBar" will be one of your options.  When you create a new project using that template, the only thing you'll need to do is to add a package dependency for MacMenuBar.  If you don't already know how to do that, the README.md file in the newly created project contains the instructions you need.

If you'd prefer to set up your project manually, see the instructions in [ManualSetup.md](ManualSetup.md).

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

In addition to menu items, we can also nest menus within menus to create submenus by simply using another `StandardMenu` instead of a menu item type. The "Open Recent..." submenu in our "File" menu is an example of this.

Finally the change we made to `AppDelegate.applicationDidFinishLaunching` by calling `setMenuBar(to: MainMenuBar())` is the line that actually sets the application's main menu to our `MainMenuBar`.  SwiftUI has to do something similar a few lines up in the line, `let contentView = ContentView()`.  It's just that the project template already provided that line, so you don't have to write it yourself.

## Custom Menu Actions

It's great that we have a menu bar now, and that we've created it in a simple declarative way, but it doesn't do much.  Let's remedy that.  You do that by creating a menu item with an *action* associated with it.

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

The `StandardMenuItemAction` examples we delcared in our application and `File` menus already have the standard key equivalents implicitly associated with them, so they don't need to be specified.   

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

3. If the menu item's `.canBeEnabled`  property is `false`, then the menu item is *disabled*.  If it's `true`, which is the default, the validation process continues to the next step.

4. If `.enabledWhen` has *not* been used to set a validation closure for the item, then the item is *enabled*.   If it does have a validation closure, validation proceeds to the next step.

5. The validation closure set with `.enabledWhen` is used to determine whether or not the menu item is enabled.  If the closure returns `true`, it is *enabled*.  If it returns `false`, it is *disabled*.

The above list extends the logic of Cocoa's built-in menu-enabling rules.  Of special note is that if both `.canBeEnabled` and `.enabledWhen`  are used and `.canBeEnabled` is `false`, that overrules the closure for `.enabledWhen`. In most cases, it makes sense to use one or the other, but not both, but it does give you a way to tell `MacMenuBar` to unconditionally disable a menu item, even if it is using `.enableWhen`.
    
## Dynamically Updating Menu Item Names

In its current state, our "Show Log" menu item is certainly usable now, but is it what Mac users really expect?  

Maybe it would be better to change the menu item to "Hide Log"  when the log is visible, and back to "Show Log"  when it's not.  That way we can toggle the log window's visible state with a key equivalent.   We can do that by modifying our action closure to either show or hide the log window based on its current visibility, and use the `.updatingTitleWith` method to specify a closure for updating the title:

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

## Dynamically Updating Menu Item State

Some menus items represent an application setting that can be enabled or disabled by the user.  That state appears as check-mark next in the menu item when the setting is enabled.  

Suppose our logger allows us to select whether or not we want more detailed logging than usual by setting its `.detailedLogging` property to `true`.  We can implement that with the `.updatingStateWith` method in `TextMenuItem` .  Let's add a new menu item to our "Debug" menu to do that.

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
                
                // >>>>>>>> ADDED THE FOLLOWING BIT <<<<<<<<<<
                TextMenuItem(title: "Detailed Logging")  { _ in
                    logger.detailedLogging.toggle()
                }
                .updatingStateWith { logger.detailedLogging ? .on : .off }
            }
            #endif
```

Now we have a  "Detailed Logging" menu item that will display whether detailed logging is currently enabled, and allows us to toggle that setting by selecting it.

The closure passed to `.updatingStateWith` is called when the menu is opened by the user, just like for `.updatingTitleWith`.  In addition to `.on` and `.off`, the closure can return `.mixed`, which is displayed as a dash in the menu item instead of a check-mark.

## Dynamically Populating Menus

Let's leave our "Debug" for now, and provide menu functionality our app's users would use.  We'll add a new "Themes" menu so that users can select the color scheme used by our app, and we'll populate with the names of our themes.  Instead of declaring each menu item individually, we can use `ForEach` to generate them for us from an array of the theme names:

```swift
            StandardMenu(title: "Themes")
            {
                ForEach(["Light", "Dark", "Sahara", "Congo", "Ocean"])
                { themeName in
                    TextMenuItem(title: themeName) { _ in setTheme(to: themeName) }
                        .updatingStateWith { currentTheme == themeName ? .on : .off }
                }
            }
```

This automatically generated "Themes" menu is a  lot better than typing out a declaration for each theme's menu item, but it still leaves something to be desired.  Suppose we later allow the user to define and save their own custom themes.  We'd want to show those too.  `ForEach` is able to do that too.  In fact, it's already dynamically populating the menu each time it's opened, it's just that we can't tell because we're giving it static input.   The parameter where we pass in our array is actually an `@autoclosure` that is called whenever the menu is opened.  So if the thing we pass in is dynamic, the contents of our "Themes" menu will be too.

Let's define a dynamic themes list called, unimaginitively,  `themesList`.   For the sake of this example, we'll just make it a computed global variable that randomly selects a subset of our existing themes.

```swift
var fixedThemes = ["Light", "Dark", "Sahara", "Congo", "Ocean"]
var themesList: [String] {
    return fixedThemes.filter { currentTheme == $0 || Bool.random() }
}
```

Then we modify our "Themes" menu declaration to use it:

```swift
            StandardMenu(title: "Themes")
            {
                ForEach(themesList) // <- CHANGED THIS
                { themeName in
                    TextMenuItem(title: themeName) { _ in setTheme(to: themeName) }
                        .updatingStateWith { currentTheme == themeName ? .on : .off }
                }
            }
```

Now our menu will list our current theme plus a different random selection of the other available themes each time it's opened.

The `ForEach` being used here is purposefully named to match the one in SwiftUI, because it serves a similar purpose, but we're using `MacMenuBar.ForEach` not `SwiftUI.ForEach`.  Whereas SwiftUI's `ForEach` needs to respond to dynamically changing data at any time during execution, MacMenuBar's `ForEach` only needs to do that when the user opens its parent menu, and of course, it generates menu items not SwiftUI `View`s.


