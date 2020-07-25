/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct FormattedText: Readable, HTMLConvertible, PlainTextConvertible {
    private var components = [Component]()

    static func read(using reader: inout Reader) -> Self {
        read(using: &reader, terminators: [])
    }

    static func readLine(using reader: inout Reader) -> Self {
        let text = read(using: &reader, terminators: ["\n"])
        if !reader.didReachEnd { reader.advanceIndex() }
        return text
    }

    static func read(using reader: inout Reader,
                     terminators: Set<Character>) -> Self {
        var parser = Parser(reader: reader, terminators: terminators)
        parser.parse()
        reader = parser.reader
        return parser.text
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        components.reduce(into: "") { string, component in
            switch component {
            case .linebreak:
                string.append("<br>")
            case .text(let text):
                string.append(String(text))
            case .styleMarker(let marker):
                let html = marker.html(usingURLs: urls, modifiers: modifiers)
                string.append(html)
            case .fragment(let fragment, let rawString):
                let html = fragment.html(
                    usingURLs: urls,
                    rawString: rawString,
                    applyingModifiers: modifiers
                )

                string.append(html)
            }
        }
    }

    func plainText() -> String {
        components.reduce(into: "") { string, component in
            switch component {
            case .linebreak:
                string.append("\n")
            case .text(let text):
                string.append(String(text))
            case .styleMarker:
                break
            case .fragment(let fragment, _):
                string.append(fragment.plainText())
            }
        }
    }

    mutating func append(_ text: FormattedText, separator: Substring = "") {
        let separator = separator.isEmpty ? [] : [Component.text(separator)]
        components += separator + text.components
    }
}

private extension FormattedText {
    enum Component {
        case linebreak
        case text(Substring)
        case styleMarker(TextStyleMarker)
        case fragment(Fragment, rawString: Substring)
    }

    struct Parser {
        var reader: Reader
        let terminators: Set<Character>
        var text = FormattedText()
        var pendingTextRange: Range<String.Index>
        var activeStyles = Set<TextStyle>()
        var activeStyleMarkers = [TextStyleMarker]()

        init(reader: Reader, terminators: Set<Character>) {
            self.reader = reader
            self.terminators = terminators
            self.pendingTextRange = reader.currentIndex..<reader.endIndex
        }

        mutating func parse() {
            var sequentialSpaceCount = 0

            while !reader.didReachEnd {
                do {
                    if !terminators.isEmpty, reader.previousCharacter != "\\" {
                        guard !terminators.contains(reader.currentCharacter) else {
                            break
                        }
                    }

                    if reader.currentCharacter.isNewline {
                        addPendingTextIfNeeded()

                        guard let nextCharacter = reader.nextCharacter else {
                            break
                        }

                        guard reader.previousCharacter != "\\" && !(sequentialSpaceCount >= 2) else {
                            text.components.append(.linebreak)
                            skipCharacter()
                            continue
                        }

                        guard !nextCharacter.isAny(of: ["\n", "#", "<", "`"]) else {
                            break
                        }

                        if !nextCharacter.isWhitespace {
                            text.components.append(.text(" "))
                        }

                        skipCharacter()
                        continue
                    }

                    if reader.currentCharacter == " " {
                        sequentialSpaceCount += 1
                    } else {
                        sequentialSpaceCount = 0
                    }

                    if reader.currentCharacter.isSameLineWhitespace {
                        guard let nextCharacter = reader.nextCharacter else {
                            break
                        }

                        guard !nextCharacter.isWhitespace else {
                            addPendingTextIfNeeded()
                            skipCharacter()
                            continue
                        }
                    }

                    guard !reader.currentCharacter.isAny(of: .allStyleMarkers) else {
                        addPendingTextIfNeeded()
                        try parseStyleMarker()
                        continue
                    }

                    if reader.currentCharacter == "<" {
                        guard let nextCharacter = reader.nextCharacter else {
                            reader.advanceIndex()
                            break
                        }

                        if nextCharacter.lowercased() == "p" {
                            break
                        }
                    }

                    guard let type = nextFragmentType() else {
                        parseNonTriggeringCharacter()
                        continue
                    }

                    addPendingTextIfNeeded()

                    let startIndex = reader.currentIndex
                    let fragment = try type.readOrRewind(using: &reader)
                    let rawString = reader.characters(in: startIndex..<reader.currentIndex)
                    text.components.append(.fragment(fragment, rawString: rawString))
                    pendingTextRange = reader.currentIndex..<reader.endIndex
                } catch {
                    parseNonTriggeringCharacter()
                }
            }

            addPendingTextIfNeeded(trimmingWhitespaces: true)
            handleUnterminatedStyleMarkers()
        }

        private mutating func addPendingTextIfNeeded(trimmingWhitespaces trimWhitespaces: Bool = false) {
            guard !pendingTextRange.isEmpty else { return }

            let textEndIndex = reader.currentIndex
            let endingTextRange = pendingTextRange.lowerBound..<textEndIndex
            var string = reader.characters(in: endingTextRange)

            if trimWhitespaces {
                string = string.trimmingTrailingWhitespaces()
            }

            text.components.append(.text(string))
            pendingTextRange = reader.currentIndex..<reader.endIndex
        }

        private mutating func parseNonTriggeringCharacter() {
            switch reader.currentCharacter {
            case "\\":
                addPendingTextIfNeeded()
                skipCharacter()
            case "&":
                let ampersandIndex = reader.currentIndex

                do {
                    try reader.read(until: ";", allowWhitespace: false)
                    addPendingTextIfNeeded()
                } catch {
                    reader.moveToIndex(ampersandIndex)
                    fallthrough
                }
            default:
                if let escaped = reader.currentCharacter.escaped {
                    addPendingTextIfNeeded()
                    text.components.append(.text(Substring(escaped)))
                    skipCharacter()
                } else {
                    reader.advanceIndex()
                }
            }
        }

        private mutating func parseStyleMarker() throws {
            let marker = try TextStyleMarker.readOrRewind(using: &reader)

            if activeStyles.contains(marker.style) {
                closeStyle(with: marker)
            } else {
                activeStyles.insert(marker.style)
                activeStyleMarkers.append(marker)
            }

            text.components.append(.styleMarker(marker))
            pendingTextRange = reader.currentIndex..<reader.endIndex
        }

        private mutating func closeStyle(with marker: TextStyleMarker) {
            turnBoldMarkerIntoItalicIfNeeded(marker)

            marker.kind = .closing
            var stylesToRemove = Set<TextStyle>()

            for otherMarker in activeStyleMarkers.reversed() {
                stylesToRemove.insert(otherMarker.style)

                if otherMarker.style == marker.style {
                    break
                }

                otherMarker.isValid = false
            }

            activeStyleMarkers.removeLast(stylesToRemove.count)
            activeStyles.subtract(stylesToRemove)
        }

        private mutating func turnBoldMarkerIntoItalicIfNeeded(_ marker: TextStyleMarker) {
            guard marker.style == .bold, activeStyles.contains(.italic) else { return }
            guard !reader.didReachEnd else { return }
            guard reader.currentCharacter.isAny(of: .boldItalicStyleMarkers) else { return }

            marker.style = .italic
            marker.rawMarkers.removeLast()
            reader.rewindIndex()
        }

        private mutating func handleUnterminatedStyleMarkers() {
            var boldMarker: TextStyleMarker?
            var italicMarker: TextStyleMarker?

            if activeStyles.isSuperset(of: [.bold, .italic]) {
                markerIteration: for marker in activeStyleMarkers {
                    switch marker.style {
                    case .bold:
                        marker.style = .italic

                        if let otherMarker = italicMarker {
                            guard marker.characterRange.lowerBound !=
                                  otherMarker.characterRange.upperBound else {
                                italicMarker = nil
                                break markerIteration
                            }

                            marker.suffix = marker.rawMarkers.removeLast()
                            marker.kind = .closing
                        } else {
                            marker.prefix = marker.rawMarkers.removeFirst()
                        }

                        boldMarker = marker
                    case .italic:
                        if let otherMarker = boldMarker {
                            guard marker.characterRange.lowerBound !=
                                  otherMarker.characterRange.upperBound else {
                                if let prefix = otherMarker.prefix {
                                    otherMarker.rawMarkers = "\(prefix)\(otherMarker.rawMarkers)"
                                } else if let suffix = otherMarker.suffix {
                                    otherMarker.rawMarkers.append(suffix)
                                }

                                boldMarker = nil
                                break markerIteration
                            }

                            marker.kind = .closing
                        }

                        italicMarker = marker
                    case .strikethrough:
                        break
                    }
                }
            }

            for marker in activeStyleMarkers {
                guard marker !== boldMarker else { continue }
                guard marker !== italicMarker else { continue }
                marker.isValid = false
            }
        }

        private mutating func skipCharacter() {
            reader.advanceIndex()
            pendingTextRange = reader.currentIndex..<reader.endIndex
        }

        private func nextFragmentType() -> Fragment.Type? {
            switch reader.currentCharacter {
            case "`": return InlineCode.self
            case "[": return Link.self
            case "!": return Image.self
            case "<": return HTML.self
            case "\\":
                if ["[","("].contains(reader.nextCharacter) {
                    return Math.self
                }
                fallthrough
            default: return nil
            }
        }
    }
}
