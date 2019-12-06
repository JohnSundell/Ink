/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Blockquote: Fragment {
    var modifierTarget: Modifier.Target { .blockquotes }

    private var text: FormattedText

    static func read(using reader: inout Reader) throws -> Blockquote {
        try reader.read(">")
        try reader.readWhitespaces()

        var text = FormattedText.readLine(using: &reader)

        while !reader.didReachEnd {
            switch reader.currentCharacter {
            case \.isNewline:
                return Blockquote(text: text)
            case ">":
                reader.advanceIndex()
            default:
                break
            }

            text.append(FormattedText.readLine(using: &reader))
        }

        return Blockquote(text: text)
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let body = text.html(usingURLs: urls, modifiers: modifiers)
        return "<blockquote><p>\(body)</p></blockquote>"
    }

    func plainText() -> String {
        text.plainText()
    }
}
