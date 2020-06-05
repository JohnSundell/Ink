/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct HTML: GroupFragment {
    var modifierTarget: Modifier.Target { .html }

    let fragments: [ParsedFragment]
    
    //private var string: Substring

    static func read(using reader: inout Reader) throws -> HTML {
        var startIndex = reader.currentIndex
        let rootElement = try reader.readHTMLElement()
        var fragments: [ParsedFragment] = []

        guard !rootElement.isSelfClosing else {
            let html = reader.characters(in: startIndex..<reader.currentIndex)
            return HTML(fragments: [ParsedFragment(fragment: RawHTML(string: html), rawString: html)])
        }

        var rootElementCount = 1
        var possibleMarkdown = false

        while !reader.didReachEnd {
            
            // if this has been tagged as possible markdown and have found a markdown character
            if possibleMarkdown,
                let type = fragmentType(for: reader.currentCharacter, nextCharacter: reader.nextCharacter) {
                // add raw html fragment
                let html = reader.characters(in: startIndex..<reader.currentIndex).trimmingTrailingWhitespaces().trimmingLeadingWhitespaces()
                fragments.append(ParsedFragment(fragment: RawHTML(string: html), rawString: html))

                let fragment: ParsedFragment
                do {
                    fragment = try makeFragment(using: type.readOrRewind, reader: &reader)
                } catch {
                    fragment = makeFragment(using: Paragraph.read, reader: &reader)
                }
                fragments.append(fragment)
                startIndex = reader.currentIndex
            } else {
                possibleMarkdown = false
            }
            
            guard !reader.didReachEnd else { break }
            
            // if two newlines are found together set possibleMarkdown flag
            if let previousCharacter = reader.previousCharacter {
                if reader.currentCharacter.isNewline && previousCharacter.isNewline {
                    possibleMarkdown = true
                }
            }
            guard reader.currentCharacter == "<" else {
                reader.advanceIndex()
                continue
            }

            guard var element = try? reader.readHTMLElement() else {
                continue
            }

            guard rootElement.name != element.name else {
                rootElementCount += 1
                continue
            }

            guard element.name.first == "/" else {
                continue
            }

            element.name = element.name.dropFirst()

            if rootElement.name == element.name {
                rootElementCount -= 1
                guard rootElementCount > 0 else { break }
            }
        }

        let html = reader.characters(in: startIndex..<reader.currentIndex).trimmingLeadingWhitespaces()
        fragments.append(ParsedFragment(fragment: RawHTML(string: html), rawString: html))
        
        return HTML(fragments: fragments)
    }
    
    static func makeFragment(using closure: (inout Reader) throws -> Fragment,
                      reader: inout Reader) rethrows -> ParsedFragment {
        let startIndex = reader.currentIndex
        let fragment = try closure(&reader)
        let rawString = reader.characters(in: startIndex..<reader.currentIndex)
        return ParsedFragment(fragment: fragment, rawString: rawString)
    }

    static func fragmentType(for character: Character,
                      nextCharacter: Character?) -> Fragment.Type? {
        switch character {
        case "#": return Heading.self
        case "!": return Image.self
        case "[": return Link.self
        case ">": return Blockquote.self
        case "`": return CodeBlock.self
        case "-" where character == nextCharacter,
             "*" where character == nextCharacter:
            return HorizontalLine.self
        case "-", "*", "+", \.isNumber: return List.self
        default: return nil
        }
    }
}

private extension Reader {
    typealias HTMLElement = (name: Substring, isSelfClosing: Bool)

    mutating func readHTMLElement() throws -> HTMLElement {
        try read("<")
        let startIndex = currentIndex

        while !didReachEnd {
            guard !currentCharacter.isWhitespace, currentCharacter != ">" else {
                let name = characters(in: startIndex..<currentIndex)
                try require(!name.isEmpty)
                let suffix = try read(until: ">", allowLineBreaks: true)

                guard name.last != "/" else {
                    return (name.dropLast(), true)
                }

                return (name, suffix.last == "/" || name == "!--")
            }

            advanceIndex()
        }

        throw Error()
    }
}

