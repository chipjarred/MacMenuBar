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
struct ThemeListButton: View
{
    let labels: [String]
    let toolTipText: String
    var isEnabled: Bool = true
    var action: (() -> Void)? = nil
    
    @State var isPressed: Bool = false
    
    // -------------------------------------
    static func plus(
        toolTip: String = "",
        isEnabled: Bool = true,
        action: (() -> Void)? = nil) -> ThemeListButton
    {
        ThemeListButton("＋", toolTip: toolTip, isEnabled: isEnabled, action: action)
    }
    
    // -------------------------------------
    static func minus(
        toolTip: String = "",
        isEnabled: Bool = true,
        action: (() -> Void)? = nil) -> ThemeListButton
    {
        ThemeListButton("－", toolTip: toolTip, isEnabled: isEnabled, action: action)
    }
    
    // -------------------------------------
    static func copy(
        toolTip: String = "",
        isEnabled: Bool = true,
        action: (() -> Void)? = nil) -> ThemeListButton
    {
        ThemeListButton(
            ["🀰", "🀱"],
            toolTip: toolTip,
            isEnabled: isEnabled,
            action: action
        )
    }
    
    // -------------------------------------
    private func singleButtonView<S: StringProtocol>(
        named name: S) -> some View
    {
        Text(String(name))
            .foregroundColor(enabledColor)
    }
    
    // -------------------------------------
    private func diagonallyStackedViews<C: RandomAccessCollection>(
        of names: C) -> some View
        where C.Element: StringProtocol, C.Index == Int
    {
        func padSize(_ index: Int) -> CGFloat { CGFloat(index) * 5 }
        
        return ZStack
        {
            if names.isEmpty {
                EmptyView()
            }
            else
            {
                ForEach(names.indices.reversed(), id: \.self)
                { i in
                    return singleButtonView(named: names[i])
                        .padding([.top, .leading], padSize(i))
                }
                .padding([.bottom, .trailing], padSize(names.count - 1))
                .padding(.leading, 1)
            }
        }
    }
    
    // -------------------------------------
    private init(
        _ imageNames: [String],
        toolTip: String,
        isEnabled: Bool,
        action: (() -> Void)?)
    {
        self.labels = imageNames
        self.toolTipText = toolTip
        self.isEnabled = isEnabled
        self.action = action
    }
    
    // -------------------------------------
    private init(
        _ imageName: String,
        toolTip: String,
        isEnabled: Bool,
        action: (() -> Void)?)
    {
        self.init([imageName], toolTip: toolTip, isEnabled: isEnabled, action: action)
    }

    // -------------------------------------
    var backColor: Color
    {
        isPressed
            ? .accentColor
            : Color.black.opacity(0)
    }
    
    // -------------------------------------
    var background: some View
    {
        Rectangle().fill(backColor)
            .frame(height: 20)
    }
    
    // -------------------------------------
    var enabledColor: Color
    {
        isEnabled
            ? .controlTextColor
            : .gray
    }
    
    // -------------------------------------
    var buttonView: some View {
        diagonallyStackedViews(of: labels).toolTip(toolTipText)
    }
    
    // -------------------------------------
    var body: some View
    {
        ZStack
        {
            background
            buttonView
                .foregroundColor(enabledColor)
        }
        .gesture(
            TapGesture()
                .updating(GestureState(initialValue: $isPressed))
                    { _,_,_ in _ = isPressed = true }
                .onEnded
                {
                    isPressed = false
                    action?()
                }
        )
    }
}
