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

import Cocoa

internal let nullChar = Character(Unicode.Scalar(0))
internal let escapeChar = Character(Unicode.Scalar(0x1B))

// -------------------------------------
/**
 `struct` to represent key equivalents for actions.
 
 The easiest way to create to create one is to add modifier with a character
 literal.  For example
 
        let quitKey = .command + "q"
 
 You can also create one from a specially formatted string.  This is suitable
 for saving key equivalents in `UserDefaults`
 
        let quitKey = KeyEquivalent(specifier: "command-q")
 
 The specifier string for this second method consists of either
 
    - a single character,
    
 or
    
    - a dash-separated list of modifiers followed by a dash, followed by a
        single character.  Legal modifiers are:
         - `"shift"`
         - `"control"`
         - `"option"`
         - `"command"`
         - `"function"`

 If a single character is specified, it is treated as though it were prefixed
 by `"command-"`
 
 You can obtain the specifier string from an existing `KeyEquivalent` via the
 `specifierString` property.
 
 - Note: For some reason macOS doesn't like combining the function key modifier
    with any others, so if it is specified, all others are ignored.
 
 - Note: `.specifierString`  and `.description` return two *different*
    `String`s, and serve different purposes:
    - `.specifierString` returns a string sutiable for passing to
        `init(specifier:)`
    - `.description` returns a string similar to the the `KeyEquivalent`'s
        displayed representation  in a menu.
 */
public struct KeyEquivalent
{
    // -------------------------------------
    public enum Modifier: CaseIterable
    {
        case shift
        case control
        case option
        case command
        case function
        
        // -------------------------------------
        internal var flags: NSEvent.ModifierFlags
        {
            switch self
            {
                case .control : return .control
                case .option  : return .option
                case .shift   : return .shift
                case .command : return .command
                case .function: return .function
            }
        }
    }
    
    public let key: Character
    public let modifiers: NSEvent.ModifierFlags
    
    public static let shift    = Self(Modifier.shift)
    public static let control  = Self(Modifier.control)
    public static let option   = Self(Modifier.option)
    public static let command  = Self(Modifier.command)
    public static let function = Self(Modifier.function)
    
    public static let none     = Self(nullChar)
    public static let escape   = Self(escapeChar)
    
    // -------------------------------------
    internal static let allNSEventModifierFlags: NSEvent.ModifierFlags =
    {
        let allMods = Modifier.allCases
        
        var mods = NSEvent.ModifierFlags(rawValue: 0)
        for modifier in allMods {
            mods.formUnion(modifier.flags)
        }
        
        return mods
    }()
    
    // -------------------------------------
    @usableFromInline
    internal init(from nsMenuItem: NSMenuItem)
    {
        var key = Character(nsMenuItem.keyEquivalent)
        var mods = nsMenuItem.keyEquivalentModifierMask
            .intersection(Self.allNSEventModifierFlags)
        
        
        if key.isUppercase
        {
            key = Character(key.lowercased())
            mods.formUnion(.shift)
        }
        
        self.key = Character(key.lowercased())
        self.modifiers = mods
    }

    // -------------------------------------
    internal init(_ key: Character, _ modifiers: [Modifier] = [])
    {
        var combinedModifiers = NSEvent.ModifierFlags()
        for modifier in modifiers {
            combinedModifiers.formUnion(modifier.flags)
        }
        
        self.init(key, combinedModifiers)
    }

    // -------------------------------------
    private init(_ modifiers: [Modifier]) { self.init(nullChar, modifiers) }

    // -------------------------------------
    private init(_ modifier: Modifier) { self.init(nullChar, modifier.flags) }

    // -------------------------------------
    internal init(_ key: Character, _ modifiers: NSEvent.ModifierFlags)
    {
        self.key = key
        
        // In macOS, .function doesn't work and play well with other modifiers.
        // It effectively removes all other modifiers.
        self.modifiers = modifiers.contains(.function)
            ? .function
            : modifiers.intersection(Self.allNSEventModifierFlags)
    }

    // -------------------------------------
    public static func + (left: Self, right: Modifier) -> Self
    {
        assert(left.key == nullChar)
        
        return Self(nullChar, left.modifiers.union(right.flags))
    }

    // -------------------------------------
    public static func + (left: Self, right: Character) -> Self
    {
        assert(left.key == nullChar)
        
        return Self(right, left.modifiers)
    }
    
    // -------------------------------------
    public func set(in nsMenuItem: NSMenuItem)
    {
        nsMenuItem.keyEquivalent = key == nullChar ? "" : String(key)
        nsMenuItem.keyEquivalentModifierMask = modifiers
    }
}

// MARK:- Equatable conformance
// -------------------------------------
extension KeyEquivalent: Equatable
{
    // -------------------------------------
    public static func == (left: Self, right: Self) -> Bool
    {
        let left = left.normalized
        let right = right.normalized
        
        return left.key == right.key && left.modifiers == right.modifiers
    }
    
    // -------------------------------------
    private var normalized: Self
    {
        
        var key = self.key
        var modifiers = self.modifiers
        
        if key.isLowercase && modifiers.contains(.shift)
        {
            key = Character(key.uppercased())
            modifiers.subtract(.shift)
        }
        else if key.isUppercase {
            modifiers.subtract(.shift)
        }
        
        return Self(key, modifiers)
    }
}

// -------------------------------------
extension KeyEquivalent.Modifier: CustomStringConvertible
{
    public var description: String
    {
        switch self
        {
            case .control : return "^"
            case .option  : return "⌥"
            case .shift   : return "⇧"
            case .command : return "⌘"
            case .function: return "fn"
        }
    }
}

// -------------------------------------
extension KeyEquivalent: CustomStringConvertible
{
    // -------------------------------------
    public var description: String
    {
        if key == nullChar { return "" }
        
        // I want them in this particular order, because that's how they appear
        // in combinations in menus.
        var allCases: [Modifier] =
        [
            .control,
            .shift,
            .option,
            .command,
            .function
        ]
        
        assert(
            Set(allCases).union(Modifier.allCases) == Set(allCases),
            "Update the allCases array above to include missing cases in their "
            + "correct display order"
        )
        
        /*
         Make sure we cover all cases - the above array makes some duplicated
         maintenance necessary for correct ordering, but at least we can
         automatically ensure that we include all the cases.
         */
        for mod in Modifier.allCases {
            if !allCases.contains(mod) { allCases.append(mod) }
        }
        

        var modifiers = self.modifiers
        if key.isUppercase { modifiers.formUnion(.shift) }
        
        var s = ""
        if modifiers.contains(.function)
        {
            // macOS doesn't like function to share with other modifiers.
            s += "\(Modifier.function)"
        }
        else {
            for modifier in allCases
            {
                if modifiers.contains(modifier.flags) { s += "\(modifier)" }
            }
        }
        
        // FIXME: Need to translate special keys - like arrows, page-up, etc...
        s += "\(key.uppercased())"
        
        return s
    }
}
