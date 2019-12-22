/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

struct InlineCode: Fragment {
    var modifierTarget: Modifier.Target { .inlineCode }
    
    private var code: String

    static func read(using reader: inout Reader) throws -> InlineCode {
        let startingMarkerCount = reader.readCount(of: "`")
        try require(startingMarkerCount > 0)
        var code = ""
        var nonSpaceEncountered = false
        while !reader.didReachEnd {
            switch reader.currentCharacter {
            case \.isNewline:
                code.append(" ") // specified replacement in CommonMark spec
                reader.advanceIndex()
            case "`":
                let markerCount = reader.readCount(of: "`")

                if markerCount == startingMarkerCount {
                    if nonSpaceEncountered && code.count >= 3 {
                        if code.first == " " && code.last == " " {
                            let trimmedCode = code.dropLast().dropFirst()
                            return InlineCode(code: String(trimmedCode))
                        }
                    }
                    return InlineCode(code: code)
                } else {
                    code.append(String(repeating: "`", count: markerCount))
                    // that last backtick could have been the last; let the loop continue but be careful
                }
                
            default:
                if let escaped = reader.currentCharacter.escaped {
                    code.append(escaped)
                } else {
                    code.append(reader.currentCharacter)
                }
                nonSpaceEncountered = true
                reader.advanceIndex()
            }
        }

        throw Reader.Error()
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        return "<code>\(code)</code>"
    }

    func plainText() -> String {
        code
    }
}
