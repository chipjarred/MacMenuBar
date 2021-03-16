//
//  MenuBuilder.swift
//  
//
//  Created by Chip Jarred on 2/20/21.
//

// -------------------------------------
@_functionBuilder
public struct MenuBuilder
{
    // -------------------------------------
    public static func buildBlock() -> [MenuElement] {
        return []
    }
    
    // -------------------------------------
    public static func buildBlock(
        _ items: MenuElement...) -> [MenuElement]
    {
        return items
    }
}
