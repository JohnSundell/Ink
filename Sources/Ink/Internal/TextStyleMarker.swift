/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal final class TextStyleMarker: Readable, HTMLConvertible {
    var style: TextStyle
    var rawMarkers: String
    let characterRange: Range<String.Index>
    var kind: Kind = .opening
    var isValid = true
    var prefix: Character?
    var suffix: Character?

    private init(style: TextStyle, rawMarkers: String, characterRange: Range<String.Index>) {
        self.style = style
        self.rawMarkers = rawMarkers
        self.characterRange = characterRange
    }

    static func read(using reader: inout Reader) throws -> Self {
        let startIndex = reader.currentIndex

        if reader.currentCharacter.isAny(of: .boldItalicStyleMarkers) {
            let firstMarker = reader.currentCharacter
            reader.advanceIndex()

            if !reader.didReachEnd, reader.currentCharacter.isAny(of: .boldItalicStyleMarkers) {
                let secondMarker = reader.currentCharacter
                let markers = String([firstMarker, secondMarker])
                reader.advanceIndex()

                return Self(
                    style: .bold,
                    rawMarkers: markers,
                    characterRange: startIndex..<reader.currentIndex
                )
            }

            return Self(
                style: .italic,
                rawMarkers: String(firstMarker),
                characterRange: startIndex..<reader.currentIndex
            )
        }

        try reader.read("~")
        try reader.read("~")

        return Self(
            style: .strikethrough,
            rawMarkers: "~~",
            characterRange: startIndex..<reader.currentIndex
        )
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        guard isValid else { return rawMarkers }

        let leadingTag: String

        switch kind {
        case .opening: leadingTag = "<"
        case .closing: leadingTag = "</"
        }

        let prefix = self.prefix.map(String.init) ?? ""
        let suffix = self.suffix.map(String.init) ?? ""
        return prefix + leadingTag + style.htmlTagName + ">" + suffix
    }
}

extension TextStyleMarker {
    enum Kind {
        case opening
        case closing
    }
}
