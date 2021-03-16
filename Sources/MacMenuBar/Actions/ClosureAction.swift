//
//  ClosureAction.swift
//  
//
//  Created by Chip Jarred on 2/23/21.
//

import Foundation

// -------------------------------------
public struct ClosureAction: Action
{
    public typealias ActionClosure = (_: Any?) -> Void
    
    public var closure: ActionClosure
    public var keyEquivalent: KeyEquivalent? = nil
    public var isEnabled: Bool = true
    
    // -------------------------------------
    public init(_ closure: @escaping ActionClosure) { self.closure = closure }
    
    // -------------------------------------
    public init(keyEquivalent: KeyEquivalent, closure: @escaping ActionClosure)
    {
        self.init(closure)
        self.keyEquivalent = keyEquivalent
    }
    
    // -------------------------------------
    /*
     `target` is ignored for `ClosureAction`s
     */
    public func performActionSelf(
        on target: ActionResponder?,
        for sender: Any?) -> Bool
    {
        guard isEnabled else { return false }
        closure(sender)
        return true
    }
}
