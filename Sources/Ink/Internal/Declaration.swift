/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal enum Declaration: Readable {
    case url(name: String, url: URL)

    static func read(using reader: inout Reader) throws -> Self {
        try reader.read("[")
        let name = try reader.read(until: "]")
        try reader.read(":")
        try reader.readWhitespaces()
        let url = reader.readUntilEndOfLine()

        return .url(name: name.lowercased(), url: url)
    }
}
