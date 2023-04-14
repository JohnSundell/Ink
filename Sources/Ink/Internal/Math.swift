/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Math: Fragment {
    var modifierTarget: Modifier.Target { .math }
    
    private var displayMode: Bool
    private var tex: String
    
    static func read(using reader: inout Reader) throws -> Math {
        reader.advanceIndex()
        let displayMode: Bool
        let closingCharacter: Character
        if reader.currentCharacter == "[" {
            displayMode = true
            closingCharacter = "]"
        } else {
            displayMode = false
            closingCharacter = ")"
        }
        reader.advanceIndex()
        reader.discardWhitespacesAndNewlines()
        
        var tex = ""
        // TeX math mode does not care about the whitespace count/type.
        var previousCharacterIsSpace = false
        
        while !reader.didReachEnd {
            guard let nextCharacter = reader.nextCharacter else {
                throw Reader.Error()
            }
            
            switch reader.currentCharacter {
            case \.isWhitespace:
                previousCharacterIsSpace = true
                reader.discardWhitespacesAndNewlines()
            case "\\":
                if nextCharacter == closingCharacter {
                    reader.advanceIndex(by: 2)
                    return Math(displayMode: displayMode, tex: tex)
                }
                fallthrough
            default:
                if previousCharacterIsSpace {
                    tex.append(" ")
                    previousCharacterIsSpace = false
                }
                
                if let escaped = reader.currentCharacter.escaped {
                    tex.append(escaped)
                } else {
                    tex.append(reader.currentCharacter)
                }
                reader.advanceIndex()
            }
        }
        throw Reader.Error()
    }
    
    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let modeString = displayMode ? "display" : "inline"
        return "<span class=\"math \(modeString)\">\(tex)</span>"
    }
    
    func plainText() -> String {
        let plainTex: String
        if displayMode {
            plainTex = "\\[\(tex)\\]"
        } else {
            plainTex = "\\(\(tex)\\)"
        }
        return plainTex
    }
}

