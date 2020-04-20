/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Blockquote: Fragment {
    var modifierTarget: Modifier.Target { .blockquotes }

    private var paragraphs = [innerParagraph]()

    static func read(using reader: inout Reader) throws -> Blockquote {
        // This is the Blockquote object we will return.
        var blockquote = Blockquote()
        // This tracks whether the next blockquote line will start a new paragraph.
        var startNewParagraph = true
        // This gets us to the first blockquote in the document.
        try reader.read(">")

        func addTextToLastParagraph() throws {
            try require(!blockquote.paragraphs.isEmpty)
            let text = FormattedText.readLine(using: &reader)
            var lastParagraph = blockquote.paragraphs.removeLast()
            lastParagraph.text.append(text, separator: " ")
            blockquote.paragraphs.append(lastParagraph)
        }

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
                case \.isNewline:
                    // A new line after the angle bracket means that the next line will
                    // belong to a new paragraph.
                    startNewParagraph = true
                    reader.advanceIndex()
                default:
                    if startNewParagraph {
                        // Append this line to the blockquote’s array of paragraphs.
                        blockquote.paragraphs.append(
                            innerParagraph(text: FormattedText.readLine(using: &reader))
                        )
                    } else {
                        // Append this line to the already existing paragraph.
                        try addTextToLastParagraph()
                    }
                    startNewParagraph = false
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
        let body = paragraphs.reduce(into: "") { html, paragraph in
            html.append(paragraph.html(usingURLs: urls, modifiers: modifiers))
        }
        // Now wrap everything in a blockquote tag.
        return "<blockquote>\(body)</blockquote>"
    }

    func plainText() -> String {
        return paragraphs.reduce(into: "") { string, paragraph in
            string.append(paragraph.text.plainText())
        }
    }
}

extension Blockquote {
    // The existing Paragraph object’s text property is marked private, so we can’t
    // access it from outside of that object. It was therefore necessary to add this
    // paragraph struct to Blockquote.
    fileprivate struct innerParagraph: HTMLConvertible {
        var text: FormattedText

        func html(usingURLs urls: NamedURLCollection,
                  modifiers: ModifierCollection) -> String {
            let textHTML = text.html(usingURLs: urls, modifiers: modifiers)
            return "<p>\(textHTML)</p>"
        }
    }
}
