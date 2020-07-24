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
        let startingDollarCount = reader.readCount(of: "$")
        let displayMode = startingDollarCount > 1 ? true : false
        
        var tex = ""
        
        while !reader.didReachEnd {
            switch reader.currentCharacter {
            case \.isNewline :
                throw Reader.Error()
            case "$":
                if displayMode {
                    reader.advanceIndex(by: 2)
                } else {
                    reader.advanceIndex()
                }
                return Math(displayMode: displayMode, tex: tex)
            default:
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
        tex
        
    }
}

