//
//  MenuElement.swift
//  
//
//  Created by Chip Jarred on 2/20/21.
//

import Foundation

// -------------------------------------
public protocol MenuElement
{
    var isItem: Bool { get }
    var title: String { get set }
    var isVisible: Bool { get set }
    var isEnabled: Bool { get set }
    
    func appendSelf<T: MacMenu>(to menu: inout T)
}

// -------------------------------------
public extension MenuElement
{
    // -------------------------------------
    func enable(_ value: Bool = true) -> Self
    {
        var copy = self
        copy.isEnabled = value
        return copy
    }
    
    // -------------------------------------
    func visible(_ value: Bool = true) -> Self
    {
        var copy = self
        copy.isVisible = value
        return copy
    }
}
