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
fileprivate extension os_unfair_lock
{
    mutating func withLock<R>(do block: () throws -> R) rethrows -> R
    {
        os_unfair_lock_lock(&self)
        defer { os_unfair_lock_unlock(&self) }
        return try block()
    }
}

// -------------------------------------
final class KeyResponder
{
    private static var respondersLock = os_unfair_lock()
    private static var keyResponders = [KeyResponder]()
    static var current: KeyResponder? {
        respondersLock.withLock { keyResponders.last }
    }
    
    private static var nextID = 0

    let id: Int = { nextID += 1; return nextID }()
    public private(set) var isResponding: Bool = false
    var closure: ((NSEvent) -> Bool)? = nil
    
    // -------------------------------------
    func onKeyDown(do body: @escaping ((NSEvent) -> Bool))
    {
        Self.respondersLock.withLock
        {
            // Nest closures so multiple closures can have a crack at the event
            let existingClosure = self.closure
            self.closure =
            {
                if !(existingClosure?($0) ?? false) {
                    return body($0)
                }
                return false
            }
            
            if let i = Self.keyResponders.lastIndex(where: { $0.id == self.id })
            {
                Self.keyResponders.remove(at: i)
            }
            Self.keyResponders.append(self)
        }
        isResponding = true
    }
    
    // -------------------------------------
    func defaultHandler() {
        onKeyDown {_ in false }
    }
    
    // -------------------------------------
    func resign()
    {
        Self.respondersLock.withLock
        {
            closure = nil
            if let i = Self.keyResponders.lastIndex(where: { $0.id == self.id })
            {
                Self.keyResponders.remove(at: i)
            }
        }
        isResponding = false
    }
}
