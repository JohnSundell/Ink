/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct URLDeclaration: Readable {
    let name: String
    let url: URL

    static func read(using reader: inout Reader,
                     references: inout NamedReferenceCollection) throws -> Self {
        try reader.read("[")

        if reader.currentCharacter == "^" {
            throw Reader.Error()
        }

        let name = try reader.read(until: "]").lowercased()
        try reader.read(":")
        try reader.readWhitespaces()
        let url = reader.readUntilEndOfLine()

        return URLDeclaration(name: name, url: url)
    }
}
