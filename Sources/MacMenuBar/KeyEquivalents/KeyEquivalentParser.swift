//
//  KeyEquivalentParser.swift
//  
//
//  Created by Chip Jarred on 2/21/21.
//

import Cocoa

// -------------------------------------
public extension KeyEquivalent
{
    // -------------------------------------
    /**
     Obtain a specifier string for this `KeyEquivalent`.
     
     This string is suitable for parsing back into a `KeyEquivalent`
     
     For example:
     
            let s = (.command + "q") // s = "command-q"
            let quitKey = KeyEquivalent(description: s)
     */
    var specifierString: String
    {
        if key == nullChar { return "" }
        
        var s: String = ""
        
        for modifier in ParserKeyword.allCases
        {
            if modifiers.contains(modifier.modifierFlag) {
                s.append("\(modifier.rawValue)-")
            }
        }
        
        if let keyName = Self.reverseKeyNameMap[key] {
            s.append(keyName)
        }
        else { s.append(key) }
        
        return s
    }
    
    // -------------------------------------
    init(specifier s: String)
    {
        guard let keyEquiv = Self.parse(s) else
        {
            fatalError(
                "illegal description for `\(Self.self)`: \"\(s)\""
            )
        }
        self = keyEquiv
    }
}

// -------------------------------------
internal extension KeyEquivalent
{
    // -------------------------------------
    fileprivate enum ParserKeyword: String, CaseIterable
    {
        case shift      = "shift"
        case control    = "control"
        case option     = "option"
        case command    = "command"
        case function   = "function"

        // -------------------------------------
        func wrap(_ keyEquivalent: KeyEquivalent) -> KeyEquivalent
        {
            return KeyEquivalent(
                keyEquivalent.key,
                keyEquivalent.modifiers.union(self.modifierFlag)
            )
        }
        
        // -------------------------------------
        var modifierFlag: NSEvent.ModifierFlags
        {
            switch self
            {
                case .shift  : return .shift
                case .control: return .control
                case .option : return .option
                case .command: return .command
                case .function: return .function
            }
        }
    }
    
    // -------------------------------------
    fileprivate enum ParseError: Error
    {
        case unknownModifier(at: String.Index)
        case repeatedModifier(at: String.Index)
        case unexpectedEndOfInput(at: String.Index)
        case illegalCharacterSpecifier(at: String.Index)
        case noKeyCharacter
    }
    
    fileprivate static let keyNameMap: [String: Character] =
    [
        "Enter"        : "\n",
        "Tab"          : "\t",
        "Backspace"    : Character(Unicode.Scalar(NSBackspaceCharacter)!),
        "Escape"       : Character(Unicode.Scalar(0x1B)),
        "Space"        : " ",
        
        "UpArrow"      : Character(Unicode.Scalar(NSUpArrowFunctionKey)!),
        "DownArrow"    : Character(Unicode.Scalar(NSDownArrowFunctionKey)!),
        "LeftArrow"    : Character(Unicode.Scalar(NSLeftArrowFunctionKey)!),
        "RightArrow"   : Character(Unicode.Scalar(NSRightArrowFunctionKey)!),
        "F1"           : Character(Unicode.Scalar(NSF1FunctionKey)!),
        "F2"           : Character(Unicode.Scalar(NSF2FunctionKey)!),
        "F3"           : Character(Unicode.Scalar(NSF3FunctionKey)!),
        "F4"           : Character(Unicode.Scalar(NSF4FunctionKey)!),
        "F5"           : Character(Unicode.Scalar(NSF5FunctionKey)!),
        "F6"           : Character(Unicode.Scalar(NSF6FunctionKey)!),
        "F7"           : Character(Unicode.Scalar(NSF7FunctionKey)!),
        "F8"           : Character(Unicode.Scalar(NSF8FunctionKey)!),
        "F9"           : Character(Unicode.Scalar(NSF9FunctionKey)!),
        "F10"          : Character(Unicode.Scalar(NSF10FunctionKey)!),
        "F11"          : Character(Unicode.Scalar(NSF11FunctionKey)!),
        "F12"          : Character(Unicode.Scalar(NSF12FunctionKey)!),
        "F13"          : Character(Unicode.Scalar(NSF13FunctionKey)!),
        "F14"          : Character(Unicode.Scalar(NSF14FunctionKey)!),
        "F15"          : Character(Unicode.Scalar(NSF15FunctionKey)!),
        "F16"          : Character(Unicode.Scalar(NSF16FunctionKey)!),
        "F17"          : Character(Unicode.Scalar(NSF17FunctionKey)!),
        "F18"          : Character(Unicode.Scalar(NSF18FunctionKey)!),
        "F19"          : Character(Unicode.Scalar(NSF19FunctionKey)!),
        "F20"          : Character(Unicode.Scalar(NSF20FunctionKey)!),
        "F21"          : Character(Unicode.Scalar(NSF21FunctionKey)!),
        "F22"          : Character(Unicode.Scalar(NSF22FunctionKey)!),
        "F23"          : Character(Unicode.Scalar(NSF23FunctionKey)!),
        "F24"          : Character(Unicode.Scalar(NSF24FunctionKey)!),
        "F25"          : Character(Unicode.Scalar(NSF25FunctionKey)!),
        "F26"          : Character(Unicode.Scalar(NSF26FunctionKey)!),
        "F27"          : Character(Unicode.Scalar(NSF27FunctionKey)!),
        "F28"          : Character(Unicode.Scalar(NSF28FunctionKey)!),
        "F29"          : Character(Unicode.Scalar(NSF29FunctionKey)!),
        "F30"          : Character(Unicode.Scalar(NSF30FunctionKey)!),
        "F31"          : Character(Unicode.Scalar(NSF31FunctionKey)!),
        "F32"          : Character(Unicode.Scalar(NSF32FunctionKey)!),
        "F33"          : Character(Unicode.Scalar(NSF33FunctionKey)!),
        "F34"          : Character(Unicode.Scalar(NSF34FunctionKey)!),
        "F35"          : Character(Unicode.Scalar(NSF35FunctionKey)!),
        "Insert"       : Character(Unicode.Scalar(NSInsertFunctionKey)!),
        "Delete"       : Character(Unicode.Scalar(NSBackspaceCharacter)!),
        "Home"         : Character(Unicode.Scalar(NSHomeFunctionKey)!),
        "Begin"        : Character(Unicode.Scalar(NSBeginFunctionKey)!),
        "End"          : Character(Unicode.Scalar(NSEndFunctionKey)!),
        "PageUp"       : Character(Unicode.Scalar(NSPageUpFunctionKey)!),
        "PageDown"     : Character(Unicode.Scalar(NSPageDownFunctionKey)!),
        "PrintScreen"  : Character(Unicode.Scalar(NSPrintScreenFunctionKey)!),
        "ScrollLock"   : Character(Unicode.Scalar(NSScrollLockFunctionKey)!),
        "Pause"        : Character(Unicode.Scalar(NSPauseFunctionKey)!),
        "SysReq"       : Character(Unicode.Scalar(NSSysReqFunctionKey)!),
        "Break"        : Character(Unicode.Scalar(NSBreakFunctionKey)!),
        "Reset"        : Character(Unicode.Scalar(NSResetFunctionKey)!),
        "Stop"         : Character(Unicode.Scalar(NSStopFunctionKey)!),
        "Menu"         : Character(Unicode.Scalar(NSMenuFunctionKey)!),
        "User"         : Character(Unicode.Scalar(NSUserFunctionKey)!),
        "System"       : Character(Unicode.Scalar(NSSystemFunctionKey)!),
        "Print"        : Character(Unicode.Scalar(NSPrintFunctionKey)!),
        "ClearLine"    : Character(Unicode.Scalar(NSClearLineFunctionKey)!),
        "ClearDisplay" : Character(Unicode.Scalar(NSClearDisplayFunctionKey)!),
        "InsertLine"   : Character(Unicode.Scalar(NSInsertLineFunctionKey)!),
        "DeleteLine"   : Character(Unicode.Scalar(NSDeleteLineFunctionKey)!),
        "InsertChar"   : Character(Unicode.Scalar(NSInsertCharFunctionKey)!),
        "DeleteChar"   : Character(Unicode.Scalar(NSDeleteCharFunctionKey)!),
        "Prev"         : Character(Unicode.Scalar(NSPrevFunctionKey)!),
        "Next"         : Character(Unicode.Scalar(NSNextFunctionKey)!),
        "Select"       : Character(Unicode.Scalar(NSSelectFunctionKey)!),
        "Execute"      : Character(Unicode.Scalar(NSExecuteFunctionKey)!),
        "Undo"         : Character(Unicode.Scalar(NSUndoFunctionKey)!),
        "Redo"         : Character(Unicode.Scalar(NSRedoFunctionKey)!),
        "Find"         : Character(Unicode.Scalar(NSFindFunctionKey)!),
        "Help"         : Character(Unicode.Scalar(NSHelpFunctionKey)!),
        "ModeSwitch"   : Character(Unicode.Scalar(NSModeSwitchFunctionKey)!),
    ]
    
    fileprivate static let reverseKeyNameMap: [Character: String] =
    {
        var rMap = [Character: String]()
        rMap.reserveCapacity(keyNameMap.count)
        
        for (key, value) in keyNameMap { rMap[value] = key }
        
        return rMap
    }()
    
    // MARK:- Parser
    // -------------------------------------
    /**
     Parse a string description for an action's  key equivalent  into a
     `KeyEquivalent`.
     
     The legal description syntax is
     
        - A single character or character name
            - A legal character name is one of:
                - `"Enter"`
                - `"Tab"`
                - `"Backspace"`
                - `"Escape"`
                - `"Space"`
                - `"UpArrow"`
                - `"DownArrow"`
                - `"LeftArrow"`
                - `"RightArrow"`
                - `"F1"`
                - `"F2"`
                - `"F3"`
                - `"F4"`
                - `"F5"`
                - `"F6"`
                - `"F7"`
                - `"F8"`
                - `"F9"`
                - `"F10"`
                - `"F11"`
                - `"F12"`
                - `"F13"`
                - `"F14"`
                - `"F15"`
                - `"F16"`
                - `"F17"`
                - `"F18"`
                - `"F19"`
                - `"F20"`
                - `"F21"`
                - `"F22"`
                - `"F23"`
                - `"F24"`
                - `"F25"`
                - `"F26"`
                - `"F27"`
                - `"F28"`
                - `"F29"`
                - `"F30"`
                - `"F31"`
                - `"F32"`
                - `"F33"`
                - `"F34"`
                - `"F35"`
                - `"Insert"`
                - `"Delete"`
                - `"Home"`
                - `"Begin"`
                - `"End"`
                - `"PageUp"`
                - `"PageDown"`
                - `"PrintScreen"`
                - `"ScrollLock"`
                - `"Pause"`
                - `"SysReq"`
                - `"Break"`
                - `"Reset"`
                - `"Stop"`
                - `"Menu"`
                - `"User"`
                - `"System"`
                - `"Print"`
                - `"ClearLine"`
                - `"ClearDisplay"`
                - `"InsertLine"`
                - `"DeleteLine"`
                - `"InsertChar"`
                - `"DeleteChar"`
                - `"Prev"`
                - `"Next"`
                - `"Select"`
                - `"Execute"`
                - `"Undo"`
                - `"Redo"`
                - `"Find"`
                - `"Help"`
                - `"ModeSwitch"`
     
     or
    
        - A dash-separated list of modifiers followed by a dash followed by a
            single character.
     
            - A legal modifier is one of:
                - `"command"`
                - `"control"`
                - `"option"`
                - `"shift"`
                - `"function"`
     
            - A modifier may only occur once in the modifier list
     
     The parser is insensitive to case when parsing the description string, so
     `"command-y"` and `"COMMAND-Y"` are equivalent.
     
     When no modifier is specified, or only `"shift"` is specified, it is
     treated as if it were prepended with `"command-"`.  This is because no
     modifier or only shift are not generally valid for key equivalents
     for actions on macOS.  If you want a bare `.character(_)` or
     `.shift(.character(_))`, you must create them explicitly.  The description
     parser will not generate them for you.
     
     Examples:
            
         // Generates .command(.character("p"))
         let keyEquiv1 = KeyEquivalent("p")
         
         // Also generates .command(.character("p"))
         let keyEquiv2 = KeyEquivalent("command-p")
         
         // Generates .command(.shift(.character("p")))
         let keyEquiv3 = KeyEquivalent("command-shift-p")
         
         // Generates .shift(.command(.character("p")))
         let keyEquiv4 = KeyEquivalent("shift-command-p")
         
         // Generates .shift(.option(.character("p")))
         let keyEquiv5 = KeyEquivalent("shift-option-p")
     
         // Generates .command(.character("\\"))
         let keyEquiv6 = KeyEquivalent("\\")
     
         // Generates .command(.character("-"))
         let keyEquiv7 = KeyEquivalent("\\-")

         // Generates .command(.character("-"))
         let keyEquiv8 = KeyEquivalent("-")
         
         // Generates .command(.option(.character(NSUpArrowFunctionKey)))
         let keyEquiv9 = KeyEquivalent("command-option-uparrow")
     
     The actual nesting order of the resulting `KeyEquivalent` `enum` is not
     guaranteed, nor important, except that the `.character` value is always
     the most deeply nested, and must always occur last in the `description`
     string.

     - Parameter description: `String` containing description of the key
        equivalent to be parsed
     
     - Returns: On success, the `KeyEquivalent`  described by `description`.
        On failure, `nil`
     */
    static func parse(_ description: String) -> KeyEquivalent?
    {
        guard description.count != 0 else { return nil }
        
        do
        {
            var modifiers: Set<ParserKeyword> = []
            
            var keyEquiv = try parse(
                description.lowercased()[...],
                modifiers: &modifiers
            )
            
            for curModifier in ParserKeyword.allCases
            {
                if modifiers.contains(
                    ParserKeyword(rawValue: curModifier.rawValue)!)
                {
                    keyEquiv = curModifier.wrap(keyEquiv)
                }
            }
            
            /*
             If the KeyEquivalent is unmodified or only has a .shift modifier,
             we add a .command modifier.
             */
            let mods = keyEquiv.modifiers
            if mods.subtracting(.shift).isEmpty {
                keyEquiv = ParserKeyword.command.wrap(keyEquiv)
            }
            
            return keyEquiv
        }
        catch let error as ParseError {
            emitError(error, in:description)
        }
        catch { fatalError("Unexpected error: \(error.localizedDescription)") }
        
        return nil
    }
    
    // -------------------------------------
    fileprivate static func parse(
        _ src: Substring,
        modifiers: inout Set<ParserKeyword>) throws -> KeyEquivalent
    {
        if src.isEmpty {
            throw ParseError.unexpectedEndOfInput(at: src.startIndex)
        }
        
        let nextCharIndex = src.index(after: src.startIndex)
        guard let dashIndex =
            src[nextCharIndex...].firstIndex(where: { $0 == "-" })
        else { return try parseLast2(src) }
        
        let token = String(src[..<dashIndex])
        guard let keyword = ParserKeyword(rawValue: token) else {
            throw ParseError.unknownModifier(at: src.startIndex)
        }

        if modifiers.contains(keyword) {
            throw ParseError.repeatedModifier(at: src.startIndex)
        }
        modifiers.insert(keyword)
                    
        return try parse(
            src[src.index(after: dashIndex)...],
            modifiers: &modifiers
        )
    }
    
    // -------------------------------------
    fileprivate static func parseLast2(_ src: Substring) throws -> KeyEquivalent
    {
        guard src.count > 0 else { throw ParseError.noKeyCharacter }
        
        if src.index(after: src.startIndex) == src.endIndex {
            return Self(src.first!)
        }
        
        if let namedKey = keyNameMap[String(src)] {
            return Self(namedKey)
        }
        
        throw ParseError.illegalCharacterSpecifier(at: src.startIndex)
    }

    // MARK:- Error emission
    // -------------------------------------
    fileprivate static func emitError(_ error: ParseError, in src: String)
    {
        let msg = "error: \(errorMessage(error, in: src))"
        print(msg)
        if !runningDebugBuildInXCTest {
            assertionFailure(msg)
        }
    }
    
    // -------------------------------------
    fileprivate static func errorMessage(
        _ error: ParseError,
        in src: String) -> String
    {
        var message = ""
        var position: String.Index? = nil
        
        switch error
        {
            case .noKeyCharacter:
                message =
                    "No key equivalent character was specified in \"\(src)\""
                
            case .repeatedModifier(at: let errPos):
                message = "Modifier already specified"
                position = errPos
            
            case .unknownModifier(at: let errPos):
                message = "Unknown modifier"
                position = errPos
                    
            case .unexpectedEndOfInput(at: let errPos):
                message = "Unexpected end of description"
                position = errPos
                
            case .illegalCharacterSpecifier(at: let errPos):
                message = "Illegal character specifier"
                position = errPos
        }
        
        guard let pos = position else { return message }
        return errorMessage(message, at: pos, in: src)
    }
    
    // -------------------------------------
    fileprivate static func errorMessage(
        _ message: String,
        at position: String.Index,
        in src: String) -> String
    {
        return"\(message):\n\"\(src)\"\n \(indent(to: position, in: src))^"
    }
    
    // -------------------------------------
    fileprivate static func indent(
        to position: String.Index,
        in src: String) -> String
    {
        var spaces = ""
        var i = src.startIndex
        
        while i != position
        {
            spaces.append(" ")
            i = src.index(after: i)
        }
        
        return spaces
    }
}
