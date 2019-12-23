/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct CodeBlock: Fragment {
    var modifierTarget: Modifier.Target { .codeBlocks }

//    private static let marker: Character = "`"

    private var language: Substring
    private var code: String

    static func read(using reader: inout Reader) throws -> CodeBlock {
        let marker = reader.currentCharacter // ` or ~ are expected but later need to implement indented code blocks.
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
            if reader.currentCharacter == marker, reader.previousCharacter == "\n" {  // faster to fail out on rarer marker and currentCharacter func
                let markerCount = reader.readCount(of: marker)

                if markerCount >= startingMarkerCount {
                    // now comes the tricky part; if there is something else after the marker,
                    // then it needs the whole line needs to end up in the emitted code.
                    // The marker and any whitespace is OK and won't need escaping.
                    // We will read any whitespace but ignore the error throw if there are none.
                    let theWhitespace = try? reader.readWhitespaces()
                    guard !reader.didReachEnd else { break } // We could have just read the last char and it is still a good code block.
                    if reader.currentCharacter == "\n" {
                        break // great we had a proper ending; break to emit the code block
                    } else {
                        // This is the tricky case; add the marker and the whitespace back and then continue in the loop to get any other characters properly escaped.
                        code.append(String(repeating: marker, count: markerCount))
                        if let white = theWhitespace {
                            code.append(String(white))
                        }
                    }
                } else { // The marker was not long enough so we put it in the code and fall through.
                    code.append(String(repeating: marker, count: markerCount))
                    guard !reader.didReachEnd else { break } // Unless we just read the last char and it is still a good code block.
                }
            }

            // I think we can now use the substring methods here too rather than copy to string
            code.append(reader.currentCharacter)
            

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
        let languageClass = language.isEmpty ? "" : " class=\"language-\(htmlEscapeASubstring(language.split(separator: " ")[0]))\""
        return "<pre><code\(languageClass)>\(htmlEscapeAString(code))</code></pre>"
    }

    func plainText() -> String {
        code
    }
}
