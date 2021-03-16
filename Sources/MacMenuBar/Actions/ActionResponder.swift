//
//  ActionResponder.swift
//  
//
//  Created by Chip Jarred on 2/23/21.
//

import Cocoa

// -------------------------------------
public protocol ActionResponder
{
    func responds(to action: Action) -> Bool
    func performAction(_ action: Action, for sender: Any?)
}
