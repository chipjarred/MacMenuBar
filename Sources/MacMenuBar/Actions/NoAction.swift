//
//  NoAction.swift
//  
//
//  Created by Chip Jarred on 2/23/21.
//

import Foundation

// -------------------------------------
public struct NoAction: Action
{
    public init() { }
    
    // -------------------------------------
    public var keyEquivalent: KeyEquivalent?
    {
        get { nil }
        set { }
    }
    
    // -------------------------------------
    public var isEnabled: Bool
    {
        get { false }
        set { }
    }
    
    // -------------------------------------
    public func performActionSelf(
        on target: ActionResponder?,
        for sender: Any?) -> Bool
    {
        return false
    }
}
