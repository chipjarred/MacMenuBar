//
//  SelectorAction.swift
//  
//
//  Created by Chip Jarred on 2/23/21.
//

import Foundation

// -------------------------------------
public struct SelectorAction: Action
{
    public var selector: Selector? = nil
    public var keyEquivalent: KeyEquivalent? = nil
    
    init(keyEquivalent: KeyEquivalent?, selector: Selector?)
    {
        self.selector = selector
        self.keyEquivalent = keyEquivalent
    }
    
    // -------------------------------------
    private var _isEnabled: Bool = true
    public var isEnabled: Bool
    {
        get { return _isEnabled && selector != nil }
        set { _isEnabled = newValue }
    }
    
    // -------------------------------------
    public func performActionSelf(
        on target: ActionResponder?,
        for sender: Any?) -> Bool
    {
        guard _isEnabled, let nsTarget = target as? NSObject else {
            return false
        }
        
        nsTarget.performAction(self, for: sender)
        return true
    }
}
