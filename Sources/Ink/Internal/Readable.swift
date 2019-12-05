/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal protocol Readable {
    static func read(using reader: inout Reader) throws -> Self
}

extension Readable {
    static func readOrRewind(using reader: inout Reader) throws -> Self {
//        guard reader.previousCharacter != "\\" else {
//            throw Reader.Error()
//        }
// Not sure why this is here it is interfering with proper backslash handling
        let previousReader = reader

        do {
            return try read(using: &reader)
        } catch {
            reader = previousReader
            throw error
        }
    }
}
