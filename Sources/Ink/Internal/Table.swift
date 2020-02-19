/**
 *  Ink
 *  Copyright (c) John Sundell 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

struct Table: Fragment {
    var modifierTarget: Modifier.Target { .tables }

    private var header: [FormattedText]
    private var body: [[FormattedText]]
    private var alignments: [Alignment]

    static func read(using reader: inout Reader) throws -> Table {
        var header: [FormattedText] = []
        var body: [[FormattedText]] = [[]]
        var alignments: [Alignment] = []

        while !reader.didReachEnd {
            guard reader.currentCharacter == "|" else { break }

            // Advance reader from here to here
            // +-------------------+       +
            // |                           |
            // v v-------------------------+
            // | table | cells |
            reader.advanceIndex()
            reader.discardWhitespaces()

            // Read FormattedText from here to here (trailing spaces are removed automatically)
            //   +---------------------+       +
            //   |                             |
            //   v     v-----------------------+
            // | table | cells |
            let text: FormattedText = .read(using: &reader, terminators: ["|", "\n"])
            guard !reader.didReachEnd else { break }

            // If the reader is at "|", we should continue parsing this line
            if reader.currentCharacter == "|" {
                body[body.count - 1].append(text)
            // If the reader is at "\n", we should move to the next line
            } else {
                body.append([])
                reader.advanceIndex()
            }
        }

        // We can be here by being at end of file, or on a new row
        // If we are at the end of file, the previous character should have been "|"
        // If we are on a new row, the last character should have been a "\n"
        if reader.previousCharacter != "|", reader.previousCharacter != "\n" {
            throw Reader.Error()
        }

        let columnCount = body[0].count

        // If we are done parsing the table, remove the empty array we appended
        if body.last?.isEmpty == true {
            body.removeLast()
        }

        if body.count > 1 {
            // If the second line's cells only contain "-" and ":", we have a header
            let hasHeader = body[1].allSatisfy { formattedText in
                formattedText.plainText().filter { !["-", ":"].contains($0) }.isEmpty
            }

            if hasHeader {
                // The header row and delimiter row must have the same number of cells
                guard body[0].count == body[1].count else {
                    throw Reader.Error()
                }

                // Create alignments based on leading and trailing ":"
                alignments = body[1].map {
                    let cell = $0.plainText()
                    switch (cell.first, cell.last) {
                    case (":", ":"):
                        return .center
                    case (":", _):
                        return .left
                    case (_, ":"):
                        return .right
                    default:
                        return .none
                    }
                }

                // Move the header row from body to header, and remove the delimiter row
                header = body.removeFirst()
                body.removeFirst()
            }
        }

        for rowIndex in body.indices {
            switch body[rowIndex].count {
            // If row has fewer columns than it should, pad with empty cells
            case let num where num < columnCount:
                body[rowIndex].append(contentsOf: Array(repeating: FormattedText(), count: columnCount - num))
            // If row has more columns than it should, discard the extras
            case let num where num > columnCount:
                body[rowIndex].removeLast(num - columnCount)
            default:
                continue
            }
        }

        // Fill alignment array if there is no header
        if header.isEmpty {
            alignments = Array(repeating: .none, count: columnCount)
        }

        return Table(header: header, body: body, alignments: alignments)
    }

    func html(usingURLs urls: NamedURLCollection, modifiers: ModifierCollection) -> String {
        var tableString = ""

        let headerString = zip(header, alignments).reduce("") { (headerString, cell) in
            let (cell, alignment) = cell
            return headerString
                + "<th\(alignment.attribute)>\(cell.html(usingURLs: urls, modifiers: modifiers))</th>"
        }

        if !headerString.isEmpty {
            tableString += "<thead><tr>\(headerString)</tr></thead>"
        }

        let rowStrings = body.map { row in
            zip(row, alignments).reduce("") { (rowString, cell) in
                let (cell, alignment) = cell
                return rowString
                    + "<td\(alignment.attribute)>\(cell.html(usingURLs: urls, modifiers: modifiers))</td>"
            }
        }

        if !rowStrings.isEmpty {
            let bodyString = rowStrings.reduce("") { (bodyString, rowString) in
                bodyString + "<tr>\(rowString)</tr>"
            }

            tableString += "<tbody>\(bodyString)</tbody>"
        }

        return "<table>\(tableString)</table>"
    }

    func plainText() -> String {
        let columnCount = alignments.count
        var columnWidths = Array(repeating: 0, count: columnCount)

        if !header.isEmpty {
            columnWidths = header.map {
                $0.plainText().count
            }
        }

        if !body.isEmpty {
            for row in body {
                columnWidths = zip(columnWidths, row).map {
                    let (width, cell) = $0
                    return max(width, cell.plainText().count)
                }
            }
        }

        var plainText = ""

        let header = zip(self.header, columnWidths).map { (title, width) in
            title.plainText().padding(toLength: width, withPad: " ", startingAt: 0)
        }
        let divider = columnWidths.map { String(repeating: "-", count: $0) }
        let body = self.body.map { row in
            zip(row, columnWidths).map { (cell, width) in
                cell.plainText().padding(toLength: width, withPad: " ", startingAt: 0)
            }
        }

        if !header.isEmpty {
            plainText += "| \(header.joined(separator: " | ")) |\n"
            plainText += "| \(divider.joined(separator: " | ")) |\n"
        }

        if !body.isEmpty {
            body.forEach { row in
                plainText += "| \(row.joined(separator: " | ")) |\n"
            }
        }

        return plainText
    }
}

private extension Table {
    enum Alignment {
        case none
        case left
        case center
        case right

        var attribute: String {
            switch self {
            case .none:
                return ""
            case .left:
                return #" align="left""#
            case .center:
                return #" align="center""#
            case .right:
                return #" align="right""#
            }
        }
    }
}
