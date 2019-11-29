/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Heading: Fragment {
    var modifierTarget: Modifier.Target { .headings }

    private var level: Int
    private var text: FormattedText

    static func read(using reader: inout Reader) throws -> Heading {
        let level = reader.readCount(of: "#")
        try require(level > 0 && level < 7)
        try reader.readWhitespaces()
        let text = FormattedText.read(using: &reader, terminator: "\n", context: .withinBlock)

        return Heading(level: level, text: text)
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        var body = text.html(usingURLs: urls, modifiers: modifiers)

        if !body.isEmpty {
            let lastCharacterIndex = body.index(before: body.endIndex)
            var trimIndex = lastCharacterIndex

            while body[trimIndex] == "#", trimIndex != body.startIndex {
                trimIndex = body.index(before: trimIndex)
            }

            if trimIndex != lastCharacterIndex {
                body = String(body[..<trimIndex])
            }
        }

        let tagName = "h\(level)"
        return "<\(tagName)>\(body)</\(tagName)>"
    }
}
