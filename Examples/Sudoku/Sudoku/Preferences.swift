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

import SwiftUI

// -------------------------------------
final class Preferences: ObservableObject, Codable
{
    static var shared: Preferences { AppDelegate.shared.prefs }
    
    var customThemes: [Theme] = Theme.initialThemes
    var recentBookmarks: [URLBookmark] = []
    
    // -------------------------------------
    func setTheme(named name: String)
    {
        if name == Theme.light.name { theme = .light }
        if name == Theme.dark.name { theme = .dark }
        
        if let newTheme = customThemes.first(where: { $0.name == name }) {
            theme = newTheme
        }
        sortThemes()
    }
    
    // -------------------------------------
    func updateSystemTheme()
    {
        let systemTheme = Theme.system
        if theme.name == systemTheme.name {
            theme = systemTheme
        }
    }
    
    // -------------------------------------
    func themeNamed(_ name: String) -> Theme?
    {
        [.light, .dark, .system].first { $0.name == name }
            ?? customThemes.first { $0.name == name }
    }
    
    // -------------------------------------
    func isUniqueThemeName(name: String) -> Bool {
        themeNamed(name) == nil
    }

    @Published var theme: Theme = .dark
    
    // -------------------------------------
    init() { }
    
    // -------------------------------------
    func reset()
    {
        customThemes = Theme.initialThemes
        theme = .system
        recentBookmarks.removeAll()
        sortThemes()
    }
    
    // -------------------------------------
    func addRecent(bookmark: URLBookmark)
    {
        if let i =
            recentBookmarks.firstIndex(where: {$0.path == bookmark.path })
        {
            recentBookmarks.remove(at: i)
        }
        recentBookmarks.append(bookmark)
    }
    
    // -------------------------------------
    public func updateRecent(bookmark: URLBookmark, at index: Int) {
        recentBookmarks.insert(bookmark, at: 0)
    }
    
    // -------------------------------------
    public func addCustomTheme(_ newTheme: Theme)
    {
        assert(isUniqueThemeName(name: newTheme.name))
        
        customThemes.append(newTheme)
        sortThemes()
    }
    
    // -------------------------------------
    public func removeCustomTheme(_ theme: Theme)
    {
        if let i = customThemes.firstIndex(where: { $0.id == theme.id })
        {
            customThemes.remove(at: i)
            if self.theme.id == theme.id {
                self.theme = .system
            }
        }
    }
    
    // -------------------------------------
    public func updateTheme(_ theme: Theme, to newTheme: Theme)
    {
        if let i = customThemes.firstIndex(where: { $0.id == theme.id }) {
            customThemes[i] = newTheme
        }
        sortThemes()
        if self.theme.id == theme.id { self.theme = newTheme }
    }
        
        // -------------------------------------
    private func sortThemes() {
        customThemes.sort { $0.name < $1.name }
    }
    
    // MARK:- Coding Conformance
    // -------------------------------------
    public enum CodingKey: Swift.CodingKey
    {
        case theme
        case customThemes
        case recentBookmarks
    }
    
    // -------------------------------------
    public required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKey.self)
        self.theme = try container.decode(Theme.self, forKey: .theme)
        self.customThemes =
            try container.decode([Theme].self, forKey: .customThemes)
        self.recentBookmarks = try container.decodeIfPresent(
            [URLBookmark].self,
            forKey: .recentBookmarks
        ) ?? []
    }
    
    // -------------------------------------
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKey.self)
        try container.encode(theme, forKey: .theme)
        try container.encode(customThemes, forKey: .customThemes)
        try container.encode(recentBookmarks, forKey: .recentBookmarks)
    }
}
