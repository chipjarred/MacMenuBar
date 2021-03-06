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

import Foundation

// -------------------------------------
public struct SelectorAction: Action
{
    public var selector: Selector? = nil
    public var keyEquivalent: KeyEquivalent? = nil
    public var enabledValidator: (() -> Bool)? = nil
    
    // -------------------------------------
    @inlinable
    public init(keyEquivalent: KeyEquivalent?, selector: Selector?)
    {
        self.selector = selector
        self.keyEquivalent = keyEquivalent
    }
    
    // -------------------------------------
    public var canBeEnabled: Bool = true
    
    // -------------------------------------
    public var isEnabled: Bool
    {
        guard canBeEnabled && selector != nil else { return false }
        
        if let validator = enabledValidator {
            return validator()
        }
        
        let responderChain = ResponderChain(forContextualMenu: false)
        return nil != responderChain.firstResponder {
            $0.responds(to: selector)
        }
    }
    
    // -------------------------------------
    public func performActionSelf(
        on target: ActionResponder?,
        for sender: Any?) -> Bool
    {
        guard canBeEnabled, let nsTarget = target as? NSObject else {
            return false
        }
        
        nsTarget.performAction(self, for: sender)
        return true
    }
}
