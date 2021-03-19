# Configuring a New Xcode Project for MacMenuBar

These instructions are for configuring a new project that was created using Apple's `App` template that comes with Xcode. 

Since Xcode's starter project template for a macOS SwiftUI app isn't set up for `MacMenuBar` there are few things you have to change to make it ready.

1. Add `MacMenuBar` as a Swift Package Dependency in your app. In Xcode select `Swift Packages` from the `File` menu, then `Add Package Dependency`.  Then fill-in the URL for this package: [https://github.com/chipjarred/MacMenuBar.git](https://github.com/chipjarred/MacMenuBar.git)

2. Remove  the `Main.storyboard` file.  Just like you don't use a Storyboard for your SwiftUI `View` types, you don't use them for `MacMenuBar` either.  Just delete it (or uncheck it as belonging to the application target in the `File Inspector` side-bar on the right).

3. Change the `Main Interface` target setting.
    1. Click on the project in the Project Navigator (side bar to the left that shows files and folder)
    2. Select your application target
    3. Select the "General" tab at the top, then in the "Deployment Info" section, clear the "Main Interface" field.

4. Add `main.swift`.  With `Main.storyboard` gone, `NSApplication` won't work automagically, so you have to add a `main.swift` to provide a working entry point for your app.  It should look like this.

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

7. Test the setup by building and running the app.  You no longer have a menu bar in the app, so *you'll need to kill it using Stop button in Xcode.*

You're now ready to start building your menus.

