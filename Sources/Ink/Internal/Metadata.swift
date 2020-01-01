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
        var linesSinceLastKey: Int = 0  // check for runaway parsing before reading to the end of file
        while !reader.didReachEnd && linesSinceLastKey < 25 {
            let line = reader.readUntilEndOfLine()
            
            guard line != "---" else {
                return metadata // this is the expected end signal
            }
            if line.isEmpty {
                if reader.didReachEnd { // empty because of file end
                    if metadata.values.count > 0 {
                        return metadata // case of good metadata but end of file reached first
                    }
                }
                linesSinceLastKey += 1
                continue //make life easy for now empty lines discarded while processing
            }
            let lineAtFirstChar = line.trimmingLeadingWhitespaces()
            if lineAtFirstChar.hasPrefix("- ") { // this looks like a YAML array element
                if let lastKey = lastKey { // we have a key to comma append array item.
                    let arrayItem = lineAtFirstChar.dropFirst(2)  // dump the "- " leader
                    if let val = metadata.values[lastKey], val.isEmpty {
                        metadata.values[lastKey] = String(arrayItem) // don't add a comma if first item
                    } else {
                        metadata.values[lastKey]?.append("," + arrayItem)  // this could be empty but whatever
                    }
                }
                continue
            }
            let separatedLine = lineAtFirstChar.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            if separatedLine.count == 0 || separatedLine[0].isEmpty { // we have no key or whitespace line
                linesSinceLastKey += 1
                continue // dump the line no reasonable thing to do
            }
            if separatedLine.count == 1 && !separatedLine[0].isEmpty { // we just have data
                if let lastKey = lastKey { // add it to the last key string if we have one
                    metadata.values[lastKey]?.append(" " + trim(separatedLine[0]))
                }
                linesSinceLastKey += 1
                continue
            }
            let key = trim(separatedLine[0])
            if !key.isEmpty { //we just have a key at least
                var value = trim(separatedLine[1])
                if value.hasPrefix("[") && value.hasSuffix("]") {
                    value.removeLast(1)
                    value.removeFirst(1)
                }
                metadata.values[key] = value // if the second component is empty it will init key
                lastKey = key
                linesSinceLastKey = 0
            } else {
                linesSinceLastKey += 1  // hard to force here because whitespace is trimmed earlier - no code coverage
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
