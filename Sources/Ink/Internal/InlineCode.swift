/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

struct InlineCode: Fragment {
    var modifierTarget: Modifier.Target { .inlineCode }
    // This should probably evolve to a Substring too
    private var code: String

    static func read(using reader: inout Reader) throws -> InlineCode {
        try reader.read("`")
        var code = ""

        while !reader.didReachEnd {
            switch reader.currentCharacter {
            case \.isNewline:
                throw Reader.Error()
            case "`":
                reader.advanceIndex()
                return InlineCode(code: code)
            default:
                code.append(reader.currentCharacter)
                reader.advanceIndex()
            }
        }

        throw Reader.Error()
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        return "<code>\(htmlEscapeAString(code))</code>"
    }

    func plainText() -> String {
        code
    }
}
