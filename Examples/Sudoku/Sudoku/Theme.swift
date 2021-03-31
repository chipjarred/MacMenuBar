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
struct Theme: Identifiable
{
    var id: Int { name.hashValue }
    
    let isEditable: Bool
    
    let name: String
    var valueColor: NSColor
    var correctGuessColor: NSColor
    var incorrectGuessColor: NSColor
    var noteColor: NSColor
    var backColor: NSColor
    var incorrectBackColor: NSColor
    var borderColor: NSColor
    var invalidGuessColor: NSColor
    var validGuessColor: NSColor
    var actualGuessColor: NSColor
    var selectedNoteColor: NSColor
    var unSelectedNoteColor: NSColor
    
    var highlightBrightness: Double
    
    var font: NSFont
    var noteFont: NSFont
    
    // -------------------------------------
    static let dark = Theme(
        isEditable: false,
        name: "Dark",
        valueColor: #colorLiteral(red: 0.4242922289, green: 0.4284931421, blue: 0.4284931421, alpha: 1),
        correctGuessColor: #colorLiteral(red: 0.4619969942, green: 0.6018599302, blue: 0.4795914408, alpha: 1),
        incorrectGuessColor: #colorLiteral(red: 0.6007213083, green: 0.1422877885, blue: 0.05755158431, alpha: 1),
        noteColor: #colorLiteral(red: 0.4619969942, green: 0.6018599302, blue: 0.4795914408, alpha: 1),
        backColor: #colorLiteral(red: 0.1058067346, green: 0.1079228693, blue: 0.1079228693, alpha: 1),
        incorrectBackColor: #colorLiteral(red: 0.2623681484, green: 0.02934079099, blue: 0, alpha: 1),
        borderColor: #colorLiteral(red: 0.3109169354, green: 0.3171352741, blue: 0.3171352741, alpha: 1),
        invalidGuessColor: #colorLiteral(red: 0.5211247077, green: 0.5369163655, blue: 0.5369163655, alpha: 1),
        validGuessColor: #colorLiteral(red: 0.7140612197, green: 0.7283424441, blue: 0.7283424441, alpha: 1),
        actualGuessColor: #colorLiteral(red: 0.6040735922, green: 0.5803396516, blue: 0.3632526646, alpha: 1),
        selectedNoteColor: #colorLiteral(red: 0.6040735922, green: 0.5803396516, blue: 0.3632526646, alpha: 1),
        unSelectedNoteColor: #colorLiteral(red: 0.7140612197, green: 0.7283424441, blue: 0.7283424441, alpha: 1),
        highlightBrightness: 0.2,
        font: NSFont(name: "Chalkboard", size: 28)!,
        noteFont: NSFont(name: "Chalkboard", size: 11)!
    )
    
    // -------------------------------------
    static let light = Theme(
        isEditable: false,
        name: "Light",
        valueColor: #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1),
        correctGuessColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
        incorrectGuessColor: #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1),
        noteColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
        backColor: #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1),
        incorrectBackColor: #colorLiteral(red: 1, green: 0.4879877241, blue: 0.4620115814, alpha: 1),
        borderColor: #colorLiteral(red: 0.5693569553, green: 0.5749941529, blue: 0.5749941529, alpha: 1),
        invalidGuessColor: #colorLiteral(red: 0.5338697186, green: 0.5500475888, blue: 0.5500475888, alpha: 1),
        validGuessColor: #colorLiteral(red: 0.402498222, green: 0.4105481865, blue: 0.4105481865, alpha: 1),
        actualGuessColor: #colorLiteral(red: 0.4147295249, green: 0.2379530238, blue: 0.2626722805, alpha: 1),
        selectedNoteColor: #colorLiteral(red: 0.4147295249, green: 0.2379530238, blue: 0.2626722805, alpha: 1),
        unSelectedNoteColor: #colorLiteral(red: 0.402498222, green: 0.4105481865, blue: 0.4105481865, alpha: 1),
        highlightBrightness: 0.2,
        font: NSFont(name: "Chalkboard", size: 28)!,
        noteFont: NSFont(name: "Chalkboard", size: 11)!
    )
    
    static let initialThemes =
    [
        Theme(
            isEditable: true,
            name: "Ocean",
            valueColor: #colorLiteral(red: 0, green: 0.616694885, blue: 0.7177481724, alpha: 1),
            correctGuessColor: #colorLiteral(red: 0, green: 0.6443423983, blue: 0.2367669849, alpha: 1),
            incorrectGuessColor: #colorLiteral(red: 0.6849380045, green: 0, blue: 0.2774518246, alpha: 1),
            noteColor: #colorLiteral(red: 0, green: 0.6443423983, blue: 0.2367669849, alpha: 1),
            backColor: #colorLiteral(red: 0, green: 0.1246444351, blue: 0.238805602, alpha: 1),
            incorrectBackColor: #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1),
            borderColor: #colorLiteral(red: 0, green: 0.3942773949, blue: 0.4588847523, alpha: 1),
            invalidGuessColor: #colorLiteral(red: 0, green: 0.5481381649, blue: 0.6379575632, alpha: 1),
            validGuessColor: #colorLiteral(red: 0, green: 0.7854036292, blue: 0.653128092, alpha: 1),
            actualGuessColor: #colorLiteral(red: 0.7276651446, green: 0.8835555962, blue: 0.2545441117, alpha: 1),
            selectedNoteColor: #colorLiteral(red: 0.09117667655, green: 0.7854036292, blue: 0.2879524503, alpha: 1),
            unSelectedNoteColor: #colorLiteral(red: 0, green: 0.7854036292, blue: 0.653128092, alpha: 1),
            highlightBrightness: 0.4,
            font: NSFont(name: "Chalkboard", size: 28)!,
            noteFont: NSFont(name: "Chalkboard", size: 11)!
        ),
        Theme(
            isEditable: true,
            name: "Sahara",
            valueColor: #colorLiteral(red: 0.6716067957, green: 0.4977128586, blue: 0.2989052758, alpha: 1),
            correctGuessColor: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1),
            incorrectGuessColor: #colorLiteral(red: 0.521568656, green: 0.2156950121, blue: 0.01110394501, alpha: 1),
            noteColor: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1),
            backColor: #colorLiteral(red: 0.9883303046, green: 0.7303156257, blue: 0.4353320003, alpha: 1),
            incorrectBackColor: #colorLiteral(red: 0.9215131357, green: 0.3141539119, blue: 0.03296296965, alpha: 1),
            borderColor: #colorLiteral(red: 0.7412451206, green: 0.5493202723, blue: 0.329898504, alpha: 1),
            invalidGuessColor: #colorLiteral(red: 0.7490179632, green: 0.5682898945, blue: 0.3457369923, alpha: 1),
            validGuessColor: #colorLiteral(red: 0.6403077411, green: 0.4858100026, blue: 0.2955577615, alpha: 1),
            actualGuessColor: #colorLiteral(red: 1, green: 0.66326937, blue: 0.1313703359, alpha: 1),
            selectedNoteColor: #colorLiteral(red: 1, green: 0.66326937, blue: 0.1313703359, alpha: 1),
            unSelectedNoteColor: #colorLiteral(red: 0.6403077411, green: 0.4858100026, blue: 0.2955577615, alpha: 1),
            highlightBrightness: 0.1,
            font: NSFont(name: "Chalkboard", size: 28)!,
            noteFont: NSFont(name: "Chalkboard", size: 11)!
        ),
    ].sorted { $0.name < $1.name }
}

// -------------------------------------
extension Theme
{
    // -------------------------------------
    @available(macOS, introduced: 10.15)
    static var systemInDarkMode: Bool
    {
        return NSApplication.shared
            .effectiveAppearance.debugDescription
            .lowercased().contains("dark")
    }
    
    // -------------------------------------
    static var system: Theme
    {
        return Theme(
            from: systemInDarkMode ? .dark : .light,
            withName: "System",
            isEditable: false
        )
    }
    
    // -------------------------------------
    init(from theme: Theme, withName name: String, isEditable: Bool = true)
    {
        self.isEditable          = isEditable
        self.name                = name
        self.valueColor          = theme.valueColor
        self.correctGuessColor   = theme.correctGuessColor
        self.incorrectGuessColor = theme.incorrectGuessColor
        self.noteColor           = theme.noteColor
        self.backColor           = theme.backColor
        self.incorrectBackColor  = theme.incorrectBackColor
        self.borderColor         = theme.borderColor
        self.invalidGuessColor   = theme.invalidGuessColor
        self.validGuessColor     = theme.validGuessColor
        self.actualGuessColor    = theme.actualGuessColor
        self.selectedNoteColor   = theme.selectedNoteColor
        self.unSelectedNoteColor = theme.unSelectedNoteColor
        self.highlightBrightness = theme.highlightBrightness
        
        self.font = theme.font
        self.noteFont = theme.noteFont
    }
}

// MARK:- Codable Conformance
// -------------------------------------
extension Theme: Codable
{
    enum CodingKey: Swift.CodingKey
    {
        case isEditable
        case name
        case valueColor
        case correctGuessColor
        case incorrectGuessColor
        case noteColor
        case backColor
        case incorrectBackColor
        case borderColor
        case invalidGuessColor
        case validGuessColor
        case actualGuessColor
        case selectedNoteColor
        case unSelectedNoteColor
        
        case highlightBrightness
        
        case font
        case noteFont
   }
    
    // -------------------------------------
    init(from decoder: Decoder) throws
    {
        var container = try decoder.container(keyedBy: CodingKey.self)
        self.isEditable =
            try container.decodeIfPresent(Bool.self, forKey: .isEditable)
                ?? false
        self.name = try container.decode(String.self, forKey: .name)
        self.valueColor =
            try NSColor.decode(from: &container, forKey: .valueColor)
        self.correctGuessColor =
            try NSColor.decode(from: &container, forKey: .correctGuessColor)
        self.incorrectGuessColor =
            try NSColor.decode(from: &container, forKey: .incorrectGuessColor)
        self.noteColor =
            try NSColor.decode(from: &container, forKey: .noteColor)
        self.backColor =
            try NSColor.decode(from: &container, forKey: .backColor)
        self.incorrectBackColor =
            try NSColor.decode(from: &container, forKey: .incorrectBackColor)
        self.borderColor =
            try NSColor.decode(from: &container, forKey: .borderColor)
        self.invalidGuessColor =
            try NSColor.decode(from: &container, forKey: .invalidGuessColor)
        self.validGuessColor =
            try NSColor.decode(from: &container, forKey: .validGuessColor)
        self.actualGuessColor =
            try NSColor.decode(from: &container, forKey: .actualGuessColor)
        self.selectedNoteColor =
            try NSColor.decode(from: &container, forKey: .selectedNoteColor)
        self.unSelectedNoteColor =
            try NSColor.decode(from: &container, forKey: .unSelectedNoteColor)
        
        self.highlightBrightness =
            try container.decode(Double.self, forKey: .highlightBrightness)
        self.font = try NSFont.decode(from: &container, forKey: .font)
        self.noteFont = try NSFont.decode(from: &container, forKey: .noteFont)
    }
    
    // -------------------------------------
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKey.self)
        
        try container.encode(isEditable, forKey: .isEditable)
        try container.encode(name, forKey: .name)
        try valueColor.encode(to: &container, forKey: .valueColor)
        try correctGuessColor.encode(to: &container, forKey: .correctGuessColor)
        try incorrectGuessColor
            .encode(to: &container, forKey: .incorrectGuessColor)
        try noteColor.encode(to: &container, forKey: .noteColor)
        try backColor.encode(to: &container, forKey: .backColor)
        try incorrectBackColor
            .encode(to: &container, forKey: .incorrectBackColor)
        try borderColor.encode(to: &container, forKey: .borderColor)
        try invalidGuessColor.encode(to: &container, forKey: .invalidGuessColor)
        try validGuessColor.encode(to: &container, forKey: .validGuessColor)
        try actualGuessColor.encode(to: &container, forKey: .actualGuessColor)
        try selectedNoteColor.encode(to: &container, forKey: .selectedNoteColor)
        try unSelectedNoteColor
            .encode(to: &container, forKey: .unSelectedNoteColor)
        
        try container.encode(highlightBrightness, forKey: .highlightBrightness)
        
        try font.encode(to: &container, forKey: .font)
        try noteFont.encode(to: &container, forKey: .noteFont)
    }
}

extension Theme: Equatable { }
