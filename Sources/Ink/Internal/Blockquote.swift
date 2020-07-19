/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Blockquote: ReadableFragment {
    var modifierTarget: Modifier.Target { .blockquotes }

    private var text: FormattedText

    static func read(using reader: inout Reader,
                     references: inout NamedReferenceCollection) throws -> Blockquote {
        try reader.read(">")
        try reader.readWhitespaces()

        var text = FormattedText.readLine(using: &reader,
                                          references: &references)

        while !reader.didReachEnd {
            switch reader.currentCharacter {
            case \.isNewline:
                return Blockquote(text: text)
            case ">":
                reader.advanceIndex()
            default:
                break
            }

            text.append(FormattedText.readLine(using: &reader,
                                               references: &references))
        }

        return Blockquote(text: text)
    }

    func html(usingReferences references: NamedReferenceCollection,
              modifiers: ModifierCollection) -> String {
        let body = text.html(usingReferences: references, modifiers: modifiers)
        return "<blockquote><p>\(body)</p></blockquote>"
    }

    func plainText() -> String {
        text.plainText()
    }
}
