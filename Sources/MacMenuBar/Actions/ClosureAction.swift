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
public struct ClosureAction: Action
{
    public typealias ActionClosure = (_: Any?) -> Void
    
    public var closure: ActionClosure
    public var keyEquivalent: KeyEquivalent? = nil
    private var _isEnabled: Bool = true
    public var isEnabled: Bool
    {
        get { return _isEnabled && (enabledValidator?() ?? true) }
        set { _isEnabled = newValue }
    }
    public var enabledValidator: (() -> Bool)? = nil
    
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
