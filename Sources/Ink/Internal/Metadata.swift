/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Metadata: Readable {
    var values = [String : String]()
    enum  YamlStyle {
        /// use this case when no active key yet
        case nokey
        /// default, can also be started with ">"
        case folded
        /// to preserve newlines and space, can be started with "|"
        case block
        /// allows escaping
        case doublequoted
        /// no escaping needed
        case singlequoted
    }
    static func read(using reader: inout Reader) throws -> Metadata {
        try require(reader.readCount(of: "-") == 3)
        try reader.read("\n")

        var metadata = Metadata()
        var lastKey: String?
        var currentStyle: YamlStyle = .nokey
        var firstIndentDepth: Int = 0
        var linesSinceLastKey: Int = 0  // check for runaway parsing before reading to the end of file
        
        func unparsedWarning(warning: String, contents: String){
            // A future list of parse warnings with line number
            // this is a bit tricky because you only want to report error on a successful element
        }
        func addToKey(_ str: String, separator: String = " "){
            if let theKey = lastKey {
                if let val = metadata.values[theKey] {
                    if val.isEmpty {
                        metadata.values[theKey] = str
                    } else {
                        metadata.values[theKey]?.append(separator + str)
                    }
                } else {
                    metadata.values[theKey] = str
                }
            }
        }
        
        func processQuoteString(_ str: String) {
            if currentStyle == .doublequoted && str.hasSuffix("\"") { // double quoted item on same line
                let value = String(str.dropLast())
                // need to process escapes here before storing
                currentStyle = .nokey
                addToKey(value, separator: " ")
            } else if currentStyle == .singlequoted && str.hasSuffix("'") { // single quoted item on same line
                let value = String(str.dropLast())
                currentStyle = .nokey
                addToKey(value, separator: " ")
            } else {
                addToKey(str, separator: " ")
            }
        }
        
        
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
                switch currentStyle {
                case .nokey:
                    unparsedWarning(warning: "Empty line in metadata ignored", contents: "\n")
                case .folded, .block, .doublequoted, .singlequoted :
                    addToKey("\n", separator: "\n")
                }
                continue
            }
            let lineAtFirstChar = line.trimmingLeadingWhitespaces()
            if lineAtFirstChar.hasPrefix("- ") { // this looks like a YAML array element
                switch currentStyle {
                case .nokey:
                    unparsedWarning(warning: "Item without a key", contents: String(lineAtFirstChar))
                case .folded:
                    let arrayItem = lineAtFirstChar.dropFirst(2)  // dump the "- " leader
                    addToKey(String(arrayItem), separator: ",")
                case .block:
                    addToKey(String(line.dropFirst(firstIndentDepth)), separator: "\n") // need to drop initial indent
                case .doublequoted, .singlequoted :
                    processQuoteString(trim(lineAtFirstChar))
                }
                continue
            }
            let separatedLine = lineAtFirstChar.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            if separatedLine.count == 0 || separatedLine[0].isEmpty { // we have no key or whitespace line
                linesSinceLastKey += 1
                switch currentStyle {
                case .nokey:
                    unparsedWarning(warning: "Empty line in metadata ignored", contents: "\n")
                case .block:
                    addToKey(String(line.dropFirst(firstIndentDepth)), separator: "\n") // need to drop initial indent
                case .folded:
                    addToKey(trim(lineAtFirstChar), separator: " ")
                case .doublequoted, .singlequoted :
                    processQuoteString(trim(lineAtFirstChar))
                }
                continue
            }
            if separatedLine.count == 1 && !separatedLine[0].isEmpty { // we just have data, no colon
                linesSinceLastKey += 1
                switch currentStyle {
                case .nokey:
                    unparsedWarning(warning: "Empty line in metadata ignored", contents: "\n")
                case .block:
                    addToKey(String(line.dropFirst(firstIndentDepth)), separator: "\n") // need to drop initial indent
                case .folded:
                    addToKey(trim(lineAtFirstChar), separator: " ")
                case .doublequoted, .singlequoted :
                    processQuoteString(trim(lineAtFirstChar))
                }
                continue
            }
            let key = trim(separatedLine[0])
            if !key.isEmpty { //we just have a key at least
                // here we should evaluate the escapes in last doublequote
                var value = trim(separatedLine[1])
                let pre = value.prefix(1)
                // should really not accept a key that exists but will let it add now?
                lastKey = key
                linesSinceLastKey = 0
                switch pre {
                case "": //new key with no value on this line
                    currentStyle = .folded
                    addToKey("", separator: " ")
                case ">":
                    currentStyle = .folded
                    value = String(value.dropFirst())
                    addToKey(value, separator: " ")
                case "|":
                    currentStyle = .block
                    value = String(value.dropFirst())
                    addToKey(value, separator: "\n")
                case "\"":
                    currentStyle = .doublequoted
                    value = String(value.dropFirst())
                    processQuoteString(value)
                case "'":
                    currentStyle = .singlequoted
                    value = String(value.dropFirst())
                    processQuoteString(value)
                    
                case "[":
                    value = String(value.dropFirst())
                    if value.hasSuffix("]") { // single quoted item on same line
                        value = String(value.dropLast())
                        addToKey(value, separator: " ")
                        currentStyle = .nokey
                    }
                    // do not handle this case if array not on same line, may need new yamlStyle to handle
               default: // assume default mode
                    currentStyle = .folded
                    addToKey(value, separator: " ")
                }
                
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
