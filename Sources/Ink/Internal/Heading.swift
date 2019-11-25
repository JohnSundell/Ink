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
        let text = FormattedText.read(using: &reader, terminator: "\n")

        return Heading(level: level, text: text)
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let body = text.html(usingURLs: urls, modifiers: modifiers)
        let tagName = "h\(level)"
        return "<\(tagName)>\(body)</\(tagName)>"
    }
}
