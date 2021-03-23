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
public struct URLBookmark
{
    public private(set) var url: URL
    public private(set) var data: Data
    
    public var isFileURL: Bool { url.isFileURL }
    public var path: String { url.path }
    
    // -------------------------------------
    public func fileWrite(data: Data) throws {
        try withScopedAccess { try data.write(to: url) }
    }
    
    // -------------------------------------
    public func fileRead() throws -> Data {
        try withScopedAccess { try Data(contentsOf: url) }
    }
    
    // -------------------------------------
    public func deletingPathExtension() -> URL {
        return url.deletingPathExtension()
    }
    
    // -------------------------------------
    public var pathComponents: [String] {
        return url.pathComponents
    }

    // -------------------------------------
    public enum Error: Swift.Error
    {
        case unableToCreateBookmarkFromURL
        case unableToCreateURLFromBookmark
        case scopedAccessFailed
    }
    
    // -------------------------------------
    public init(url: URL) throws
    {
        self.url = url
        self.data = try Self.bookmark(for: url)
    }
    
    // -------------------------------------
    public init(bookmark data: Data) throws
    {
        self.data = data
        var stale = false
        self.url = try Self.url(for: data, stale: &stale)
        if stale {
            self.data = try Self.bookmark(for: url)
        }
    }
    
    // -------------------------------------
    public func withScopedAccess<R>(do block: () throws -> R) throws -> R
    {
        guard url.startAccessingSecurityScopedResource() else {
            throw Error.scopedAccessFailed
        }
        defer
        {
            DispatchQueue.main.async {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        return try block()
    }
    
    // -------------------------------------
    private static func bookmark(for url: URL) throws -> Data
    {
        do
        {
            return try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
        }
        catch
        {
            throw Error.unableToCreateBookmarkFromURL
        }
    }
    
    // -------------------------------------
    private static func url(for bookmark: Data, stale: inout Bool) throws -> URL
    {
        do
        {
            return try URL(
                resolvingBookmarkData: bookmark,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &stale
            )
        }
        catch
        {
            throw Error.unableToCreateURLFromBookmark
        }
    }
}

// MARK:- Codable Conformance
// -------------------------------------
fileprivate  let hexDigits = [Character]("0123456789abcdef")

// -------------------------------------
extension URLBookmark: Codable
{
    // -------------------------------------
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.singleValueContainer()
        
        let hexStr = try container.decode(String.self)
        guard let d = Self.data(forHexString: hexStr) else
        {
            throw DecodingError.dataCorrupted(
                DecodingError.Context.init(
                    codingPath: container.codingPath,
                    debugDescription:
                        "Failed to convert hex string to binary: \"\(hexStr)\""
                )
            )
        }
        
        try self.init(bookmark: d)
    }
    
    // -------------------------------------
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.singleValueContainer()
        let hexStr = Self.hexString(for: data)
        try container.encode(hexStr)
    }
    
    // -------------------------------------
    private static func data(forHexString s: String) -> Data?
    {
        let s = s.lowercased()
        do
        {
            var data = Data()
            
            var byte: UInt8 = 0
            var i = s.startIndex
            while i != s.endIndex
            {
                byte = try valueFor(hexDigit: s[i]) << 4
                i = s.index(after: i)
                
                guard i != s.endIndex else { return nil }
                
                byte |= try valueFor(hexDigit: s[i])
                data.append(byte)
                i = s.index(after: i)
            }
            
            return data
        }
        catch { return nil }
    }
    
    // -------------------------------------
    private static func hexString(for data: Data) -> String
    {
        var hexStr = ""
        hexStr.reserveCapacity(data.count * 2)
        
        for byte in data
        {
            let intByte = Int(byte)
            
            hexStr.append(hexDigits[intByte >> 4])
            hexStr.append(hexDigits[intByte & 0xf])
        }
        
        return hexStr
    }
    
    // -------------------------------------
    private enum Hex2BinError: Swift.Error
    {
        case hexToBytes
    }
    
    // -------------------------------------
    private static func valueFor(hexDigit: Character) throws -> UInt8
    {
        guard let value = hexDigits.firstIndex(of: hexDigit) else  {
            throw Hex2BinError.hexToBytes
        }
        
        return UInt8(value)
    }
}
