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
import Cocoa

// -------------------------------------
extension NSCoding
{
    // -------------------------------------
    func encode(
        to container: inout SingleValueEncodingContainer,
        secure: Bool = true) throws
    {
        let archiver = NSKeyedArchiver(requiringSecureCoding: secure)
        archiver.encode(self, forKey: "0")
        archiver.finishEncoding()
        try container.encode(archiver.encodedData)
    }
    
    // -------------------------------------
    func encode(
        to container: inout UnkeyedEncodingContainer,
        secure: Bool = true) throws
    {
        let archiver = NSKeyedArchiver(requiringSecureCoding: secure)
        archiver.encode(self, forKey: "0")
        archiver.finishEncoding()
        try container.encode(archiver.encodedData)
    }
    
    // -------------------------------------
    func encode<Key: CodingKey>(
        to container: inout KeyedEncodingContainer<Key>,
        forKey key: Key,
        secure: Bool = true) throws
    {
        let archiver = NSKeyedArchiver(requiringSecureCoding: secure)
        archiver.encode(self, forKey: key.stringValue)
        archiver.finishEncoding()
        try container.encode(archiver.encodedData, forKey: key)
    }

    // -------------------------------------
    static func decode(
        from container: inout SingleValueDecodingContainer,
        secure: Bool = true) throws -> Self
    {
        let unarchiver = try NSKeyedUnarchiver(
            forReadingFrom: try container.decode(Data.self)
        )
        unarchiver.decodeData()
        guard let obj = unarchiver.decodeObject(of: [Self.self], forKey: "0")
        else
        {
            throw DecodingError.valueNotFound(
                Self.self,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unable to decode from NSUnarchiver data"
                )
            )
        }
        
        guard let selfObj = obj as? Self else
        {
            throw DecodingError.typeMismatch(
                Self.self,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription:  "Type mismatch while decoding.  "
                        + "Expected \(Self.self), but got \(type(of: obj))"
                )
            )
        }
        
        return selfObj
    }

    // -------------------------------------
    static func decode(
        from container: inout UnkeyedDecodingContainer,
        secure: Bool = true) throws -> Self
    {
        let unarchiver = try NSKeyedUnarchiver(
            forReadingFrom: try container.decode(Data.self)
        )
        unarchiver.decodeData()
        guard let obj = unarchiver.decodeObject(of: [Self.self], forKey: "0")
        else
        {
            throw DecodingError.valueNotFound(
                Self.self,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unable to decode from NSUnarchiver data"
                )
            )
        }
        
        guard let selfObj = obj as? Self else
        {
            throw DecodingError.typeMismatch(
                Self.self,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription:  "Type mismatch while decoding.  "
                        + "Expected \(Self.self), but got \(type(of: obj))"
                )
            )
        }
        
        return selfObj
    }

    // -------------------------------------
    static func decode<Key: CodingKey>(
        from container: inout KeyedDecodingContainer<Key>,
        forKey key: Key,
        secure: Bool = true) throws -> Self
    {
        let unarchiver = try NSKeyedUnarchiver(
            forReadingFrom: try container.decode(Data.self, forKey: key)
        )
        unarchiver.decodeData()
        guard let obj = unarchiver.decodeObject(
                of: [Self.self],
                forKey: key.stringValue)
        else
        {
            throw DecodingError.valueNotFound(
                Self.self,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unable to decode from NSUnarchiver data"
                )
            )
        }
        
        guard let selfObj = obj as? Self else
        {
            throw DecodingError.typeMismatch(
                Self.self,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription:  "Type mismatch while decoding.  "
                        + "Expected \(Self.self), but got \(type(of: obj))"
                )
            )
        }
        
        return selfObj
    }
}
