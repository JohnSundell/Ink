/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct URLDeclaration: Readable {
    var name: String
    var url: URL
    var title: Substring?

    static func read(using reader: inout Reader) throws -> Self {
        try reader.read("[")
        let name = try reader.read(until: "]")
        try reader.read(":")
        try reader.readWhitespaces()

        var titleText: Substring? = nil
        let url = try reader.readCharacters(matching: \.isSameLineNonWhitespace)

        if !reader.didReachEnd {
			if reader.currentCharacter.isNewline {
				reader.advanceIndex()
			}
			if reader.currentCharacter.isSameLineWhitespace {
				try reader.readWhitespaces()
			}
            if let delimeter = TitleDelimeter(rawValue: reader.currentCharacter) {
                let index = reader.currentIndex
                reader.advanceIndex()
                titleText = try reader.read(until: delimeter.closing)
                reader.discardWhitespaces()
                if !reader.didReachEnd && !reader.currentCharacter.isWhitespace {
                    reader.moveToIndex(index)
                    titleText = nil
                }
            }
        }
        return URLDeclaration(name: name.lowercased(), url: url, title: titleText)
    }
}
