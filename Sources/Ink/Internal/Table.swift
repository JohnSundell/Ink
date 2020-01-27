/**
 *  Ink
 *  Copyright (c) John Sundell 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

struct Table: Fragment {
    var modifierTarget: Modifier.Target { .tables }

    private var code: String

    static func read(using reader: inout Reader) throws -> Table {
        try reader.read("|")
        reader.rewindIndex()

        var code = ""

        outerWhile: while !reader.didReachEnd {
            switch reader.currentCharacter {
            case \.isNewline:
                code += "</tr>"
                reader.advanceIndex(by: 2)
                break
            case "|":
                let line = reader.readUntilEndOfLine()

                guard line.split(separator: "|").count >= 2 else { throw Reader.Error() }

                // If line only contains header-dashes, change first row from <td> to <th>
                if String(line)
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "|", with: "")
                    .replacingOccurrences(of: "-", with: "")
                    .isEmpty {
                    code = code
                             .replacingOccurrences(of: "<td>", with: "<th>")
                             .replacingOccurrences(of: "</td>", with: "</th>")
                    break
                }

                let columns = line.split(separator: "|")
                code += "<tr>"
                columns.forEach { cell in
                    let trimmedCell = cell.trimmingLeadingWhitespaces().trimmingTrailingWhitespaces()
                    code += "<td>\(trimmedCell)</td>"
                }

                code += "</tr>"
            default:
                throw Reader.Error()
            }
        }

        guard !code.isEmpty else { throw Reader.Error() }
        code = "<table>\(code)</table>"

        return Table(code: code)
    }

    func html(usingURLs urls: NamedURLCollection, modifiers: ModifierCollection) -> String {
        code
    }

    func plainText() -> String {
        code
    }
}
