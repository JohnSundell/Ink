/**
 *  Ink
 *  Copyright (c) John Sundell 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

struct Table: Fragment {
    var modifierTarget: Modifier.Target { .tables }

    private var header: Row?
    private var rows = [Row]()
    private var columnCount = 0
    private var columnAlignments = [ColumnAlignment]()

    static func read(using reader: inout Reader) throws -> Table {
        var table = Table()

        while !reader.didReachEnd, !reader.currentCharacter.isNewline {
            guard reader.currentCharacter == "|" else {
                break
            }

            let row = try reader.readTableRow()
            table.rows.append(row)
            table.columnCount = max(table.columnCount, row.count)
        }

        guard !table.rows.isEmpty else { throw Reader.Error() }
        table.formHeaderAndColumnAlignmentsIfNeeded()
        return table
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        var html = ""
        let render: () -> String = { "<table>\(html)</table>" }

        if let header = header {
            let rowHTML = self.html(
                forRow: header,
                cellElementName: "th",
                urls: urls,
                modifiers: modifiers
            )

            html.append("<thead>\(rowHTML)</thead>")
        }

        guard !rows.isEmpty else {
            return render()
        }

        html.append("<tbody>")

        for row in rows {
            let rowHTML = self.html(
                forRow: row,
                cellElementName: "td",
                urls: urls,
                modifiers: modifiers
            )

            html.append(rowHTML)
        }

        html.append("</tbody>")
        return render()
    }

    func plainText() -> String {
        var text = header.map(plainText) ?? ""

        for row in rows {
            if !text.isEmpty { text.append("\n") }
            text.append(plainText(forRow: row))
        }

        return text
    }
}

private extension Table {
    typealias Row = [FormattedText]
    typealias Cell = FormattedText

    static let delimiters: Set<Character> = ["|", "\n"]
    static let allowedHeaderCharacters: Set<Character> = ["-", ":"]

    enum ColumnAlignment {
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

    mutating func formHeaderAndColumnAlignmentsIfNeeded() {
        guard rows.count > 1 else { return }
        guard rows[0].count == rows[1].count else { return }

        let textPredicate = Self.allowedHeaderCharacters.contains
        var alignments = [ColumnAlignment]()

        for cell in rows[1] {
            let text = cell.plainText()

            guard text.allSatisfy(textPredicate) else {
                return
            }

            alignments.append(parseColumnAlignment(from: text))
        }

        header = rows[0]
        columnAlignments = alignments
        rows.removeSubrange(0...1)
    }

    func parseColumnAlignment(from text: String) -> ColumnAlignment {
        switch (text.first, text.last) {
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

    func html(forRow row: Row,
              cellElementName: String,
              urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        var html = "<tr>"

        for index in 0..<columnCount {
            let cell = index < row.count ? row[index] : nil
            let contents = cell?.html(usingURLs: urls, modifiers: modifiers)

            html.append(htmlForCell(
                at: index,
                contents: contents ?? "",
                elementName: cellElementName
            ))
        }

        return html + "</tr>"
    }

    func htmlForCell(at index: Int, contents: String, elementName: String) -> String {
        let alignment = index < columnAlignments.count
            ? columnAlignments[index]
            : .none

        let tags = (
            opening: "<\(elementName)\(alignment.attribute)>",
            closing: "</\(elementName)>"
        )

        return tags.opening + contents + tags.closing
    }

    func plainText(forRow row: Row) -> String {
        var text = ""

        for index in 0..<columnCount {
            let cell = index < row.count ? row[index] : nil
            if index > 0 { text.append(" | ") }
            text.append(cell?.plainText() ?? "")
        }

        return text + " |"
    }
}

private extension Reader {
    mutating func readTableRow() throws -> Table.Row {
        try readTableDelimiter()
        var row = Table.Row()

        while !didReachEnd {
            let cell = FormattedText.read(
                using: &self,
                terminators: Table.delimiters
            )

            try readTableDelimiter()
            row.append(cell)

            if !didReachEnd, currentCharacter.isNewline {
                advanceIndex()
                break
            }
        }

        return row
    }

    mutating func readTableDelimiter() throws {
        try read("|")
        discardWhitespaces()
    }
}
