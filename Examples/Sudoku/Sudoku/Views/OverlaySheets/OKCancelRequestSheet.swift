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
import MacMenuBar

// -------------------------------------
protocol OKCancelRequestSheet: View
{
    var keyResponder: KeyResponder { get }
    var title: String { get }
    var description: String { get }
    var okText: String { get }
    var cancelText: String? { get }
    
    func ok()
    func cancel()
}

// -------------------------------------
extension OKCancelRequestSheet
{
    // -------------------------------------
    var body: some View
    {
        KeyResponderGroup
        {
            ZStack
            {
                Rectangle().fill(Color.controlColor).opacity(0.8)
                VStack(spacing: 0)
                {
                    Text(title).font(.title)
                        .foregroundColor(.controlTextColor)
                        .padding(.top, 20)
                        .padding(.bottom, 50)

                    Text(description)
                        .foregroundColor(.controlTextColor)
                        .padding([.leading, .trailing], 20)
                        .padding(.bottom, 40)
                    
                    HStack
                    {
                        Spacer()
                        
                        if let cancelText = self.cancelText
                        {
                            MacOSButton(
                                cancelText,
                                keyEquivalent: .command + "."
                            ) { cancel() }
                            .frame(width: 100)
                        }
                        
                        MacOSButton(okText, keyEquivalent: .none + "\r") {
                            ok()
                        }.focusable()
                        .frame(width: 100)

                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
        .transition(
            AnyTransition.opacity.animation(
                .easeInOut(duration: 0.3)
            )
        )
    }
}
