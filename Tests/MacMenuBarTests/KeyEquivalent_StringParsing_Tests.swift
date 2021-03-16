//
//  KeyEquivalent_StringParsing_Tests.swift
//  
//
//  Created by Chip Jarred on 2/21/21.
//

import XCTest
@testable import MacMenuBar

// -------------------------------------
class KeyEquivalent_StringParsing_Tests: XCTestCase
{
    // -------------------------------------
    func test_can_parse_single_character()
    {
        var actual = KeyEquivalent.parse("c")
        XCTAssertEqual(actual!, .command + "c")
        
        actual = KeyEquivalent.parse("-")
        XCTAssertEqual(actual!, .command + "-")
        
        actual = KeyEquivalent.parse("\\")
        XCTAssertEqual(actual!, .command + "\\")
    }
    
    // -------------------------------------
    func test_can_parse_singly_modified_character()
    {
        var actual = KeyEquivalent.parse("command-c")
        XCTAssertEqual(actual, .command + "c")
        
        actual = KeyEquivalent.parse("option-c")
        XCTAssertEqual(actual, .option + "c")
        
        actual = KeyEquivalent.parse("control-c")
        XCTAssertEqual(actual, .control + "c")

        // Unmofidifed keys or whose only mod is .shift add .command
        actual = KeyEquivalent.parse("shift-c")
        XCTAssertEqual(actual, .command + .shift + "c")

        
        actual = KeyEquivalent.parse("command--")
        XCTAssertEqual(actual, .command + "-")

        actual = KeyEquivalent.parse("command-\\")
        XCTAssertEqual(actual, .command + "\\")

    }
    
    // -------------------------------------
    func test_can_parse_multiply_modified_character()
    {
        var actual = KeyEquivalent.parse("command-option-c")
        XCTAssertEqual(actual, .command + .option + "c")

        actual = KeyEquivalent.parse("option-shift-c")
        XCTAssertEqual(actual, .option + .shift + "c")

        actual = KeyEquivalent.parse("control-shift-c")
        XCTAssertEqual(actual, .control + .shift + "c")
        
        actual = KeyEquivalent.parse("command-shift-c")
        XCTAssertEqual(actual, .command + .shift + "c")

        actual = KeyEquivalent.parse("command-option-shift-c")
        XCTAssertEqual(actual, .command + .option + .shift + "c")

        actual = KeyEquivalent.parse("command-option-control-shift-c")
        XCTAssertEqual(
            actual,
            .command + .option + .control + .shift + "c"
        )
    }
    
    // -------------------------------------
    func test_fails_to_parse_initial_dash_followed_by_modifier()
    {
        let actual = KeyEquivalent.parse("-command-c")
        XCTAssertNil(actual)
    }
    
    // -------------------------------------
    func test_fails_to_parse_repeated_dashes()
    {
        var actual = KeyEquivalent.parse("--")
        XCTAssertNil(actual)
        
        actual = KeyEquivalent.parse("command--c")
        XCTAssertNil(actual)
    }

    // -------------------------------------
    func test_fails_to_parse_illegal_modifier()
    {
        var actual = KeyEquivalent.parse("capsLock-c")
        XCTAssertNil(actual)
        
        actual = KeyEquivalent.parse("gsag-c")
        XCTAssertNil(actual)

        actual = KeyEquivalent.parse("c-c")
        XCTAssertNil(actual)

        actual = KeyEquivalent.parse("\\-c")
        XCTAssertNil(actual)

        actual = KeyEquivalent.parse("--c")
        XCTAssertNil(actual)
    }
}
