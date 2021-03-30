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
public extension CGPoint
{
    // -------------------------------------
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    // -------------------------------------
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)

    }
    
    // -------------------------------------
    static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    
    // -------------------------------------
    static func - (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }

    // -------------------------------------
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    // -------------------------------------
    static func * (lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        return rhs * lhs
    }

    // -------------------------------------
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    // -------------------------------------
    func midPoint(to other: CGPoint) -> CGPoint {
        return (self + other) / 2
    }
    
    // -------------------------------------
    func translate(by delta: CGSize) -> CGPoint {
        return self + CGPoint(x: delta.width, y: delta.height)
    }
    
    // -------------------------------------
    func translate(deltaX: CGFloat, deltaY: CGFloat = 0) -> CGPoint {
        self + CGSize(width: deltaX, height: deltaY)
    }
    
    // -------------------------------------
    func translate(deltaY: CGFloat) -> CGPoint {
        self + CGSize(width: 0, height: deltaY)
    }
    
    // -------------------------------------
    var vectorLength: CGFloat { sqrt(x * x + y * y)  }
}
