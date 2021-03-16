//
//  NSObject+Extension.swift
//  
//
//  Created by Chip Jarred on 2/23/21.
//

import Cocoa

// -------------------------------------
extension NSObject: ActionResponder
{
    // -------------------------------------
    public func responds(to action: Action) -> Bool
    {
        if let selector = (action as? SelectorAction)?.selector {
            return responds(to: selector)
        }
        
        return action is ClosureAction
    }
    
    // -------------------------------------
    public func performAction(_ action: Action, for sender: Any?)
    {
        if let closure = (action as? ClosureAction)?.closure {
            return closure(sender)
        }
        
        guard let selector = (action as? SelectorAction)?.selector
        else { return }
        
        assert(
            responds(to: selector),
            "\(type(of: self)) does not respond to \(selector)"
        )
        
        perform(selector, with: sender)
    }
}
