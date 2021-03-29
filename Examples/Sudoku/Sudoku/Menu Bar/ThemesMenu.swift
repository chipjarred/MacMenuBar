// Copyright 2021 Chip Jarred
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import MacMenuBar

// -------------------------------------
let themesMenu = StandardMenu(title: "Themes")
{
    TextMenuItem(title: "System") { _ in
        Preferences.shared.theme = .system
    }
    .updatingStateWith {
        Preferences.shared.theme.name == Theme.system.name ? .on : .off
    }
    
    TextMenuItem(title: Theme.light.name) { _ in
        Preferences.shared.theme = .light
    }
    .updatingStateWith {
        Preferences.shared.theme.name == Theme.light.name ? .on : .off
    }
    
    TextMenuItem(title: Theme.dark.name) { _ in
        Preferences.shared.theme = .dark
    }
    .updatingStateWith {
        Preferences.shared.theme.name == Theme.dark.name ? .on : .off
    }

    MenuSeparator()
    
    TextMenuItem(title: "Custom Themes").enabled(false)
    ForEach(Preferences.shared.customThemes)
    { theme in
        TextMenuItem(title: theme.name) { _ in
            Preferences.shared.setTheme(named: theme.name)
        }
        .indented()
        .updatingStateWith {
            Preferences.shared.theme.name == theme.name ? .on : .off
        }
    }
    
    MenuSeparator()
    TextMenuItem(title: "Edit Themes") { _ in
        AppDelegate.shared.sheetRequest.state = .editThemes
    }.enabledWhen { AppDelegate.shared.sheetRequest.state == .none }
}
