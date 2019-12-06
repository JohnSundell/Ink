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

        let language = reader
            .readUntilEndOfLine()
            .trimmingTrailingWhitespaces()

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

            if let escaped = reader.currentCharacter.escaped {
                code.append(escaped)
            } else {
                code.append(reader.currentCharacter)
            }

            reader.advanceIndex()
        }

        return CodeBlock(language: language, code: code)
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let languageClass = language.isEmpty ? "" : " class=\"language-\(language)\""
        return "<pre><code\(languageClass)>\(code)</code></pre>"
    }

    func plainText() -> String {
        code
    }
}
