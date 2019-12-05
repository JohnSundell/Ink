/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct HorizontalLine: Fragment {
    var modifierTarget: Modifier.Target { .horizontalLines }

    static func read(using reader: inout Reader) throws -> HorizontalLine {
        guard reader.currentCharacter.isAny(of: ["-", "*"]) else {
            throw Reader.Error()
        }

        try require(reader.readCount(of: reader.currentCharacter) > 2)
        try require(reader.readUntilEndOfLine().isEmpty)
        return HorizontalLine()
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        "<hr>"
    }

    func plainText() -> String {
        // Since we want to strip all HTML from plain text output,
        // there is nothing to return here, just an empty string.
        ""
    }
}
