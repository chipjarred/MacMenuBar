# Xcode Templates for MacMenuBar

This folder contains Xcode templates that set up a new projects that already already configured to use MacMenuBar.   

The only thing you have to do is to add the package dependency on MacMenuBar in `Swift Packages` menu in Xcode's `File` menu.

*I would love to configure the templates so that even manually adding the package dependency is unnecessary, but have yet to find a way to do it.  If you have figured out how to configure package dependencies in a project template, please let me know!*

### Template Descriptions

- `App using MacMenuBar`: Creates the same starter app as the one supplied by Apple's Xcode template, but with all of the main menu items implemented using MacMenuBar instead of a Storyboard.

## Installing the Templates

You can install the templates automatically using the `install.bash`  provided in this directory, or manually.

### Install Using `install.bash`

1. Open `Terminal`
2. Change directories to this directory.  For example, if you cloned `MacMenuBar` into a `Packages` directory in your home directory, you'd type
```bash
cd ~/Pacakges/MacMenuBar/Templates
```
3. Run `install.bash`
```bash
./install.bash
```
If you get an error that you can't execute the script, you just need to set its executable bit first:
```bash
chmod -x install.bash
./install.bash
```

### Manual Installation
1. In Finder press command-shift-G.  Then type `~/Library/Developer/Xcode`.
2. If there is no `Templates` folder, create it.
3. Open the `Templates` folder
4. If folders named `File Templates` and `Project Templates` are missing, create them.
5. Open the `Project Templates` folder.
6. If there there is no `Applicaton` folder, create it.
7. While holding down the option key, drag the templates you want to install from within the package's `Templates` subfolders into the `Application` folder from step 6.

