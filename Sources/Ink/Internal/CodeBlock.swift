/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct CodeBlock: Fragment {
    var modifierTarget: Modifier.Target { .codeBlocks }

    private static let marker: Character = "`"

    private var language: Substring
    private var code: String

    static func read(using reader: inout Reader) throws -> CodeBlock {
        let startingMarkerCount = reader.readCount(of: marker)
        try require(startingMarkerCount >= 3)
        reader.discardWhitespaces()

        let infoString = reader
            .readUntilEndOfLine()
            .trimmingTrailingWhitespaces()
        // https://spec.commonmark.org/0.29/#fenced-code-blocks
        // cannot contain backtick
        try require(!infoString.contains("`"))
        var code = ""

        while !reader.didReachEnd {
            if code.last == "\n", reader.currentCharacter == marker {
                let markerCount = reader.readCount(of: marker)

                if markerCount == startingMarkerCount {
                    break
                } else {
                    code.append(String(repeating: marker, count: markerCount))
                    guard !reader.didReachEnd else { break }
                }
            }

            if let escaped = escapedHtml(reader.currentCharacter) {
                code.append(escaped)
            } else {
                code.append(reader.currentCharacter)
            }

            reader.advanceIndex()
        }
        // store the raw Substring for expediency here. The first word is the word is the language and the rest has no meaning.
        // trim to the first word on output
        return CodeBlock(language: infoString, code: code)
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        // https://spec.commonmark.org/0.29/#fenced-code-blocks
        // first word of any info string is actually the language added
        let languageClass = language.isEmpty ? "" : " class=\"language-\(language.split(separator: " ")[0])\""
        return "<pre><code\(languageClass)>\(code)</code></pre>"
    }

    func plainText() -> String {
        code
    }
}
