/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal enum Declaration: Readable {
    case url(name: String, url: URL)
    case footnote(Footnote)

    static func read(using reader: inout Reader) throws -> Self {
        try reader.read("[")

        let isFootnote = reader.currentCharacter == "^"
        if isFootnote {
            reader.advanceIndex()
        }

        let name = try reader.read(until: "]").lowercased()
        try reader.read(":")
        try reader.readWhitespaces()
        let contents = reader.readUntilEndOfLine()

        if isFootnote {
            return .footnote(Footnote(name: name, contents: contents))
        }
        return .url(name: name, url: contents)
    }
}
