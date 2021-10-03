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
        enum Quotes {
            case no, single, double
        }
        var valueInQuotes = Quotes.no

        while !reader.didReachEnd {
            reader.discardWhitespacesAndNewlines()
            
            //Check if we are in a value marked by quotes.
            guard valueInQuotes == .no
            else {
                
                var value = trim(reader.readUntilEndOfLine())
                
                if (value.last == "\"" && valueInQuotes == .double) ||
                    (value.last == "'" && valueInQuotes == .single){
                    valueInQuotes = .no
                    value.removeLast()
                }
                    
                if let lastKey = lastKey {
                    metadata.values[lastKey]?.append(" " + value)
                }
                    continue
            }
            
            //Check for end of metadata.
            let currentIndex = reader.currentIndex
            guard reader.readCount(of: "-") != 3
            else{
                return metadata
            }
            reader.moveToIndex(currentIndex)

            //Read until the possible end of a key marked by a colon. This reads until the end of the line if there is no colon.
            let key = try trim(reader.read(until: ":", required: false))
            
            //If there is no colon, then this must be an orphan metadata line.  Merge it into previous value.
            guard reader.previousCharacter == ":"
            else {
                if let lastKey = lastKey {
                    metadata.values[lastKey]?.append(" " + key)
                }

                continue
            }
            
            reader.discardWhitespaces()

            //Check if we are starting a value wrapped in quotes and flag accordingly
            if reader.currentCharacter == "\""
            {
                reader.advanceIndex()
                valueInQuotes = .double
            }
            if reader.currentCharacter == "'"
            {
                reader.advanceIndex()
                valueInQuotes = .single
            }
            

            var value = trim(reader.readUntilEndOfLine())

            if !value.isEmpty {
                
                if (value.last == "\"" && valueInQuotes == .double) ||
                    (value.last == "'" && valueInQuotes == .single){
                    valueInQuotes = .no
                    value.removeLast()
                }
                
                metadata.values[key] = value
                lastKey = key
            }
        }

        throw Reader.Error()
    }

    func applyingModifiers(_ modifiers: ModifierCollection) -> Self {
        var modified = self

        modifiers.applyModifiers(for: .metadataKeys) { modifier in
            for (key, value) in modified.values {
                let newKey = modifier.closure((key, Substring(key)))
                modified.values[key] = nil
                modified.values[newKey] = value
            }
        }

        modifiers.applyModifiers(for: .metadataValues) { modifier in
            modified.values = modified.values.mapValues { value in
                modifier.closure((value, Substring(value)))
            }
        }

        return modified
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
