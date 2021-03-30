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

import SwiftUI

// -------------------------------------
struct PopoverShape: Shape, InsettableShape
{
    /*
     Interpret arrowSize.height as the arrow's length, the distance it
     projects outward from the background rectangle.
     
     arrowSize.width is the distance along the background rectangle's edge
     that the arrow occupies
     */
    static let arrowSize = CGSize(width: 36, height: 18)
    var arrowEdge: Edge
    var insetDelta: CGFloat = 0
    
    // -------------------------------------
    private func backgroundRect(from rect: CGRect) -> CGRect
    {
        let arrowLength: CGSize
        
        switch arrowEdge
        {
            case .leading, .trailing:
                arrowLength = CGSize(width: Self.arrowSize.height, height: 0)
                
            case .top, .bottom:
                arrowLength = CGSize(width: 0, height: Self.arrowSize.height)
        }
        
        let bgRect = CGRect(origin: rect.origin, size: rect.size - arrowLength)
        
        switch arrowEdge
        {
            case .top, .leading:
                return bgRect.translate(by: arrowLength)
                
            default:
                return bgRect
        }
    }
    
    // -------------------------------------
    private func startEndArrorPoints(
        for rect: CGRect,
        bgRect: CGRect)
        -> (startPoint: CGPoint, endPoint: CGPoint, arrowPoint: CGPoint)
    {
        let startPoint: CGPoint
        let endPoint: CGPoint
        let arrowTipPoint: CGPoint
        
        switch arrowEdge
        {
            case .leading:
                startPoint = bgRect.topLeft.midPoint(
                    to: bgRect.bottomLeft
                ).translate(deltaY: -Self.arrowSize.width / 2)
                
                endPoint = bgRect.topLeft.midPoint(
                    to: bgRect.bottomLeft
                ).translate(deltaY: Self.arrowSize.width / 2)
                
                arrowTipPoint = rect.topLeft.midPoint(
                    to: rect.bottomLeft
                )
                
            case .trailing:
                startPoint = bgRect.topRight.midPoint(
                    to: bgRect.bottomRight
                ).translate(deltaY: Self.arrowSize.width / 2)
                
                endPoint = bgRect.topRight.midPoint(
                    to: bgRect.bottomRight
                ).translate(deltaY: -Self.arrowSize.width / 2)
                
                arrowTipPoint = rect.topRight.midPoint(
                    to: rect.bottomRight
                )
                
            case .top:
                startPoint = bgRect.topLeft.midPoint(
                    to: bgRect.topRight
                ).translate(deltaX: Self.arrowSize.width / 2)
                
                endPoint = bgRect.topLeft.midPoint(
                    to: bgRect.topRight
                ).translate(deltaX: -Self.arrowSize.width / 2)
                
                arrowTipPoint = rect.topLeft.midPoint(
                    to: rect.topRight
                )
                
            case .bottom:
                startPoint = bgRect.bottomRight.midPoint(
                    to: bgRect.bottomLeft
                ).translate(deltaX: -Self.arrowSize.width / 2)
                
                endPoint = bgRect.bottomRight.midPoint(
                    to: bgRect.bottomLeft
                ).translate(deltaX: Self.arrowSize.width / 2)
                
                arrowTipPoint = rect.bottomRight.midPoint(
                    to: rect.bottomLeft
                )
        }
        
        return (startPoint, endPoint, arrowTipPoint)
    }
    
    // -------------------------------------
    private func lineRoundingCorner(
        from start: CGPoint,
        to end: CGPoint,
        around rect: CGRect,
        in path: inout Path,
        cornerRadius: CGFloat) -> (newStart: CGPoint, isFinished: Bool)
    {
        let hRadius = CGSize(width: cornerRadius, height: 0)
        let vRadius = CGSize(width: 0, height: cornerRadius)
        
        switch end
        {
            case rect.topLeft:
                assert(start.x == end.x, "Not on rectangle edge")
                assert(start.y > end.y, "Not going clockwise")
                path.addLine(to: end + vRadius)
                let p = end + hRadius
                path.addQuadCurve(to: p, control: end)
                return (p, false)
                
            case rect.topRight:
                assert(start.y == end.y, "Not on rectangle edge")
                assert(start.x < end.x, "Not going clockwise")
                path.addLine(to: end - hRadius)
                let p = end + vRadius
                path.addQuadCurve(to: p, control: end)
                return (p, false)

            case rect.bottomRight:
                assert(start.x == end.x, "Not on rectangle edge")
                assert(start.y < end.y, "Not going clockwise")
                path.addLine(to: end - vRadius)
                let p = end - hRadius
                path.addQuadCurve(to: p, control: end)
                return (p, false)

            case rect.bottomLeft:
                assert(start.y == end.y, "Not on rectangle edge")
                assert(start.x > end.x, "Not going clockwise")
                path.addLine(to: end + hRadius)
                let p = end - vRadius
                path.addQuadCurve(to: p, control: end)
                return (p, false)

            default: break
        }
        
        if end.y == rect.minY
        {
            assert(start.y == end.y, "Not on rectangle")
            assert(start.x < end.x, "Not going clockwise")
            let p = end - hRadius
            path.addLine(to: p)
            return (p, true)
        }
        
        if end.x == rect.maxX
        {
            assert(start.x == end.x, "Not on rectangle")
            assert(start.y < end.y, "Not going clockwise")
            let p = end - vRadius
            path.addLine(to: p)
            return (p, true)
        }
        
        if end.y == rect.maxY
        {
            assert(start.y == end.y, "Not on rectangle")
            assert(start.x > end.x, "Not going clockwise")
            let p = end + hRadius
            path.addLine(to: p)
            return (p, true)
        }
        
        if end.x == rect.minX
        {
            assert(start.x == end.x, "Not on rectangle")
            assert(start.y > end.y, "Not going clockwise")
            let p = end + vRadius
            path.addLine(to: p)
            return (p, true)
        }
        
        fatalError("Not on rectangle edges")
    }
    
    // -------------------------------------
    private func mainPath(
        from startPoint: CGPoint,
        to endPoint: CGPoint,
        around rect: CGRect,
        cornerRadius: CGFloat) -> Path
    {
        var path = Path()
        
        var curPoint = startPoint
        path.move(to: curPoint)
        
        var finished = false
        repeat
        {
            var nextPoint: CGPoint
            
            if curPoint.y == rect.minY
            {
                nextPoint = rect.topRight
                if curPoint != startPoint && nextPoint.y == endPoint.y {
                    nextPoint = endPoint
                }
            }
            else if curPoint.x == rect.maxX
            {
                nextPoint = rect.bottomRight
                if curPoint != startPoint && nextPoint.x == endPoint.x {
                    nextPoint = endPoint
                }
            }
            else if curPoint.y == rect.maxY
            {
                nextPoint = rect.bottomLeft
                if curPoint != startPoint && nextPoint.y == endPoint.y {
                    nextPoint = endPoint
                }
            }
            else if curPoint.x == rect.minX
            {
                nextPoint = rect.topLeft
                if curPoint != startPoint && nextPoint.x == endPoint.x {
                    nextPoint = endPoint
                }
            }
            else { fatalError("Invalid current point for path") }
            
            (curPoint, finished) = lineRoundingCorner(
                from: curPoint,
                to: nextPoint,
                around: rect,
                in: &path,
                cornerRadius: cornerRadius
            )
        } while !finished
        
        return path
    }
    
    // -------------------------------------
    private func addArrowPoint(
        from start: CGPoint,
        to end: CGPoint,
        through arrowTip: CGPoint,
        on rect: CGRect,
        in path: inout Path,
        cornerRadius: CGFloat)
    {
        let line1 = arrowTip - start
        let line1Delta = cornerRadius * (line1 / line1.vectorLength)
        var p11 = start + line1Delta
        let p12 = arrowTip - line1Delta
        p11 = p11.midPoint(to: p12)
        
        let line2 = end - arrowTip
        let line2Delta = cornerRadius * (line2 / line2.vectorLength)
        let p21 = arrowTip + line2Delta
        var p22 = end - line2Delta
        p22 = p21.midPoint(to: p22)
        
        let hDelta = CGSize(width: cornerRadius, height: 0)
        let vDelta = CGSize(width: 0, height: cornerRadius)

        let arrowControl: CGPoint
        let c1: CGPoint
        let c2: CGPoint
        if start.x == rect.minX
        {
            c1 = start - vDelta
            c2 = end + vDelta
            arrowControl = arrowTip - hDelta / 2
        }
        else if start.y == rect.minY
        {
            c1 = start + hDelta
            c2 = end - hDelta
            arrowControl = arrowTip - vDelta / 2
        }
        else if start.x == rect.maxX
        {
            c1 = start + vDelta
            c2 = end - vDelta
            arrowControl = arrowTip + hDelta / 2
        }
        else if start.y == rect.maxY
        {
            c1 = start - hDelta
            c2 = end + hDelta
            arrowControl = arrowTip + vDelta / 2
        }
        else { fatalError("Unreachable") }

        path.addQuadCurve(to: p12, control: c1)
        path.addQuadCurve(to: p21, control: arrowControl)
        path.addQuadCurve(to: end, control: c2)
    }
    
    // -------------------------------------
    public func path(in rect: CGRect) -> Path
    {
        let cornerRadius: CGFloat = 6
        let bgRect = backgroundRect(from: rect)
        
        let (startPoint, endPoint, arrowTipPoint) = startEndArrorPoints(
            for: rect,
            bgRect: bgRect
        )
        
        var path = mainPath(
            from: startPoint,
            to: endPoint,
            around: bgRect,
            cornerRadius: cornerRadius
        )
        
        addArrowPoint(
            from: endPoint,
            to: startPoint,
            through: arrowTipPoint,
            on: bgRect,
            in: &path,
            cornerRadius: cornerRadius
        )
        
        return path
    }
    
    // -------------------------------------
    public func inset(by amount: CGFloat) -> some InsettableShape
    {
        var newShape = self
        newShape.insetDelta += amount
        return newShape
    }
}

// -------------------------------------
struct PopoverShape_Previews: PreviewProvider
{
    // -------------------------------------
    static var previews: some View
    {
        VStack
        {
            HStack
            {
                PopoverShape(arrowEdge: .leading)
                    .stroke(Color.blue)
                    .frame(width: 100, height: 100)
                PopoverShape(arrowEdge: .top)
                    .stroke(Color.blue)
                    .frame(width: 100, height: 100)
            }
            HStack
            {
                PopoverShape(arrowEdge: .trailing)
                    .stroke(Color.blue)
                    .frame(width: 100, height: 100)
                PopoverShape(arrowEdge: .bottom)
                    .stroke(Color.blue)
                    .frame(width: 100, height: 100)
            }
        }
    }
}
