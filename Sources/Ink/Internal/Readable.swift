/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal protocol Readable {
    static func read(using reader: inout Reader,
                     references: inout NamedReferenceCollection) throws -> Self
}

extension Readable {
    static func readOrRewind(using reader: inout Reader,
                             references: inout NamedReferenceCollection) throws -> Self {
        guard reader.previousCharacter != "\\" else {
            throw Reader.Error()
        }

        let previousReader = reader

        do {
            return try read(using: &reader,
                            references: &references)
        } catch {
            reader = previousReader
            throw error
        }
    }
}
