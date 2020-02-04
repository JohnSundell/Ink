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
        var code = ""

        while !reader.didReachEnd {
            guard reader.currentCharacter == "|" else { break }

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
                continue
            }

            let columns = line.split(separator: "|")
            code += "<tr>"
            columns.forEach { cell in
                let trimmedCell = cell.trimmingLeadingWhitespaces().trimmingTrailingWhitespaces()
                code += "<td>\(trimmedCell)</td>"
            }

            code += "</tr>"
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
