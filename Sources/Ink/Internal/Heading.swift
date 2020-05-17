/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Heading: Fragment {
    var modifierTarget: Modifier.Target { .headings }
    var level: Int

    private var text: FormattedText

    static func read(using reader: inout Reader) throws -> Heading {
        let level = reader.readCount(of: "#")
        try require(level > 0 && level < 7)
        try reader.readWhitespaces()
        let text = FormattedText.read(using: &reader, terminators: ["\n"])

        return Heading(level: level, text: text)
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let body = stripTrailingMarkers(
            from: text.html(usingURLs: urls, modifiers: modifiers)
        )

        let tagName = "h\(level)"
        return "<\(tagName)>\(body)</\(tagName)>"
    }

    func plainText() -> String {
        stripTrailingMarkers(from: text.plainText())
    }
}

private extension Heading {
    func stripTrailingMarkers(from text: String) -> String {
        guard !text.isEmpty else { return text }

        let lastCharacterIndex = text.index(before: text.endIndex)
        var trimIndex = lastCharacterIndex

        while text[trimIndex] == "#", trimIndex != text.startIndex {
            trimIndex = text.index(before: trimIndex)
        }

        if trimIndex != lastCharacterIndex {
            return String(text[..<trimIndex])
        }

        return text
    }
}
