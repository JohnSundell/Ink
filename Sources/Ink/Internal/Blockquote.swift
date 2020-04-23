/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Blockquote: Fragment {
    var modifierTarget: Modifier.Target { .blockquotes }

    private var items = [Fragment]()

    static func read(using reader: inout Reader) throws -> Blockquote {
        // This is the Blockquote object we will return.
        var blockquote = Blockquote()
        // This gets us to the first blockquote in the document.
        try reader.read(">")

        // Ensures that currentCharacter refers to the first angle bracket.
        reader.rewindIndex()
        while !reader.didReachEnd {
            // The nested switch can advance the reader, causing currentCharacter to
            // change by the time control returns to the outer switch; best to lock down
            // the first character.
            let firstChar = reader.currentCharacter
            switch firstChar {
            case ">":
                // Everything now depends on the first non-space character after the
                // angle bracket.
                while !reader.didReachEnd && (
                    reader.currentCharacter == ">" || reader.currentCharacter == " "
                ) {
                    reader.advanceIndex()
                }
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
                case \.isNewline:
                    reader.advanceIndex()
                default:
                    blockquote.items.append(
                        Paragraph.read(using: &reader, ignorePrefix: ">"))
                }
            case \.isNewline:
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
