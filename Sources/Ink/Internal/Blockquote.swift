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
        reader.rewindUntilBeginningOfLine()
        while !reader.didReachEnd {

            if let ignorePrefix = ignorePrefix {
                if let lookAhead = reader.lookAheadAtCharacters(ignorePrefix.count) {
                    if lookAhead == ignorePrefix {
                        for _ in 0..<ignorePrefix.count {
                            reader.advanceIndex()
                        }
                        reader.discardWhitespaces()
                    }
                }
            }

            let firstChar = reader.currentCharacter
            switch firstChar {
            case ">":
                reader.advanceIndex()  // Move past the angle bracket.
                reader.discardWhitespaces()
                let nextChar = reader.currentCharacter
                switch nextChar {
                case "#":
                    let heading = try Heading.read(using: &reader)
                    blockquote.items.append(heading)
                    if reader.currentCharacter == "\n" {
                        reader.advanceIndex()
                    }
                case "-", "*", "+", \.isNumber:
                    let list = try List.read(using: &reader, ignorePrefix: ">")
                    blockquote.items.append(list)
                case ">":
                    let nestedBlockquote = try Blockquote.read(using: &reader, ignorePrefix: ">")
                    blockquote.items.append(nestedBlockquote)
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
