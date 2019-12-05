/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Metadata: Readable {
    var values = [String : String]()

    static func read(using reader: inout Reader) throws -> Metadata {
        try require(reader.readCount(of: "-") == 3)
        try reader.read("\n")

        var metadata = Metadata()
        var lastKey: String?

        while !reader.didReachEnd {
            reader.discardWhitespacesAndNewlines()

            guard reader.currentCharacter != "-" else {
                try require(reader.readCount(of: "-") == 3)
                return metadata
            }

            let key = try trim(reader.read(until: ":", required: false))

            guard reader.previousCharacter == ":" else {
                if let lastKey = lastKey {
                    metadata.values[lastKey]?.append(" " + key)
                }

                continue
            }

            let value = trim(reader.readUntilEndOfLine())

            if !value.isEmpty {
                metadata.values[key] = value
                lastKey = key
            }
        }

        throw Reader.Error()
    }
}

private extension Metadata {
    static func trim(_ string: Substring) -> String {
        String(string
            .trimmingLeadingWhitespaces()
            .trimmingTrailingWhitespaces()
        )
    }
}
