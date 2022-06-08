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

// -------------------------------------
public protocol Action
{
    var keyEquivalent: KeyEquivalent? { get set }
    var isEnabled: Bool { get }
    var canBeEnabled: Bool { get set }
    var enabledValidator: (() -> Bool)? { get set }
        
    // -------------------------------------
   /**
     - Returns: `true` if the action was performed; otherwise, `false`
     */
    func performActionSelf(
        on target: ActionResponder?,
        for sender: Any?) -> Bool
}

// -------------------------------------
public extension Action
{
    static var none: Action { NoAction() as Action }
    
    // -------------------------------------
    /**
     Determine if the specified `KeyEquivalent` is bound to this `Action`
     
     - Parameter keyEquivalent: The `KeyEquivalent` to check
     
     - Returns: `true` if this `Action` is bound to the specified
        `KeyEquivalent`; otherwise, `false`
     */
    func responds(to keyEquivalent: KeyEquivalent) -> Bool
    {
        guard let k = self.keyEquivalent, k.key != nullChar else {
            return false
        }
        return keyEquivalent == k
    }
    
    // -------------------------------------
    /**
     Perform this `Action` on `target` or on the first `ActionResponder` in the
     responder chain that will respond to it.
     
     If `target` is specified, it is checked first.   If it responds to this
     `Action` it's `performAction(_:, for:)` method is called..  If it does not
     or is `nil`, then the current responder chain is searched, starting from
     the application's `NSApp.keyWindow`, and ending with `NSApp` itself.

     - Returns: `true` if the action was performed; otherwise, `false`
     */
    func performAction(on target: ActionResponder?, for sender: Any?) -> Bool
    {
        guard isEnabled, let target = findResponder(target: target) else {
            return false
        }
        
        return performActionSelf(on: target, for: sender)
    }
    
    // -------------------------------------
    /**
     Searches the responder chain for an `ActionResponder` for the this `Action`
     
     If `target` is specified, it is checked first.   If it responds to this
     `Action` it is returned.  If it does not or is `nil`, then the current
     responder chain is searched, starting from the application's
     `NSApp.keyWindow`, and ending with `NSApp` itself.
     
     - Parameter target: an optional `ActionResponder` to start the search.
     
     - Returns: A responder that responds to the specified action, or `nil` if
        none respond to this `Action`.
     */
    func findResponder(target: ActionResponder?) -> ActionResponder?
    {
        if target?.responds(to: self) ?? false { return target }
        
        for responder in ResponderChain() {
            if responder.responds(to: self) { return responder }
        }
        
        return nil
    }
}
