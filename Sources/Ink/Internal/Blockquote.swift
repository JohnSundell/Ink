/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Blockquote: Fragment {
    var modifierTarget: Modifier.Target { .blockquotes }

    private var items = [Fragment]()

    static func read(using reader: inout Reader) throws -> Blockquote {
        try read(using: &reader, ignorePrefix: nil)
    }

    static func read(using reader: inout Reader, ignorePrefix: String?) throws -> Blockquote {
        var blockquote = Blockquote()
        try reader.read(">")

        // Ensures that currentCharacter refers to the first angle bracket.
        reader.rewindIndex()
        // These defaults were chosen arbitrarily to avoid activating the ignore case
        // when not needed.
        let ignoreFirstChar = ignorePrefix?.first ?? "ñ"
        let ignorePrefixString = ignorePrefix ?? ""
        while !reader.didReachEnd {
            let previousCharacter = reader.previousCharacter ?? "\n"
            let lookAhead = reader.lookAheadAtCharacters(ignorePrefixString.count) ?? "⫝"
            // The nested switch can advance the reader, causing currentCharacter to
            // change by the time control returns to the outer switch; best to lock down
            // the first character.
            let firstChar = reader.currentCharacter
            switch firstChar {
            case ignoreFirstChar where previousCharacter.isNewline && lookAhead == ignorePrefixString:
                for _ in 0..<ignorePrefixString.count {
                    reader.advanceIndex()
                }
                do {
                    try reader.readWhitespaces()
                } catch is Reader.Error { }
            case ">":
                // Move past the angle bracket.
                reader.advanceIndex()
                // Check the first non-space character after the angle bracket for block-
                // level elements.
                do {
                    try reader.readWhitespaces()
                } catch is Reader.Error { }  // Not a problem if there is no whitespace.
                let nextChar = reader.currentCharacter
                switch nextChar {
                case "#":
                    let heading = try Heading.read(using: &reader)
                    blockquote.items.append(heading)
                    // Heading does not consume the trailing newline.
                    reader.advanceIndex()
                case "-", "*", "+", \.isNumber:
                    let list = try List.read(using: &reader, ignorePrefix: ">")
                    blockquote.items.append(list)
                case ">":
                    reader.rewindIndex()
                    reader.rewindIndex()
                    let innerBlockquote = try Blockquote.read(using: &reader, ignorePrefix: ">")
                    blockquote.items.append(innerBlockquote)
                case \.isNewline:
                    reader.advanceIndex()
                default:
                    blockquote.items.append(
                        Paragraph.read(using: &reader, ignorePrefix: ">"))
                }
            case \.isNewline:
                reader.advanceIndex()
                return blockquote
            default:
                break
            }
        }
        return blockquote
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        // First get the HTML representation of the paragraphs.
        let body = items.reduce(into: "") { html, item in
            html.append(item.html(usingURLs: urls, modifiers: modifiers))
        }
        // Now wrap everything in a blockquote tag.
        return "<blockquote>\(body)</blockquote>"
    }

    func plainText() -> String {
        return items.reduce(into: "") { string, item in
            string.append(item.plainText())
        }
    }
}
