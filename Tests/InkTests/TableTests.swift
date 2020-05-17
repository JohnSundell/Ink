/**
 *  Ink
 *  Copyright (c) John Sundell 2020
 *  MIT license, see LICENSE file for details
 */

import XCTest
import Ink

final class TableTests: XCTestCase {
    func testTableWithoutHeader() {
        let html = MarkdownParser().html(from: """
        | HeaderA | HeaderB |
        | CellA   | CellB   |
        """)

        XCTAssertEqual(html, """
        <table><tbody>\
        <tr><td>HeaderA</td><td>HeaderB</td></tr>\
        <tr><td>CellA</td><td>CellB</td></tr>\
        </tbody></table>
        """)
    }

    func testTableWithHeader() {
        let html = MarkdownParser().html(from: """
        | HeaderA | HeaderB | HeaderC |
        | ------- | ------- | ------- |
        | CellA1  | CellB1  | CellC1  |
        | CellA2  | CellB2  | CellC2  |
        """)

        XCTAssertEqual(html, """
        <table>\
        <thead><tr><th>HeaderA</th><th>HeaderB</th><th>HeaderC</th></tr></thead>\
        <tbody>\
        <tr><td>CellA1</td><td>CellB1</td><td>CellC1</td></tr>\
        <tr><td>CellA2</td><td>CellB2</td><td>CellC2</td></tr>\
        </tbody>\
        </table>
        """)
    }

    func testTableWithUnalignedColumns() {
        let html = MarkdownParser().html(from: """
        | HeaderA                        | HeaderB    | HeaderC |
        | ------------------------------ | ----------- | ------------ |
        | CellA1                    | CellB1      | CellC1       |
        | CellA2                   | CellB2       | CellC2        |
        """)

        XCTAssertEqual(html, """
        <table>\
        <thead><tr><th>HeaderA</th><th>HeaderB</th><th>HeaderC</th></tr></thead>\
        <tbody>\
        <tr><td>CellA1</td><td>CellB1</td><td>CellC1</td></tr>\
        <tr><td>CellA2</td><td>CellB2</td><td>CellC2</td></tr>\
        </tbody>\
        </table>
        """)
    }

    func testTableWithOnlyHeader() {
        let html = MarkdownParser().html(from: """
        | HeaderA   | HeaderB   | HeaderC |
        | ----------| ----------| ------- |
        """)

        XCTAssertEqual(html, """
        <table>\
        <thead><tr><th>HeaderA</th><th>HeaderB</th><th>HeaderC</th></tr></thead>\
        </table>
        """)
    }

    func testIncompleteTable() {
        let html = MarkdownParser().html(from: """
        | one | two |
        | three |
        | four | five | six
        """)

        XCTAssertEqual(html, "<p>| one | two | | three | | four | five | six</p>")
    }

    func testInvalidTable() {
        let html = MarkdownParser().html(from: """
        |123 Not a table
        """)

        XCTAssertEqual(html, "<p>|123 Not a table</p>")
    }

    func testTableBetweenParagraphs() {
        let html = MarkdownParser().html(from: """
        A paragraph.

        | A | B |
        | C | D |

        Another paragraph.
        """)

        XCTAssertEqual(html, """
        <p>A paragraph.</p>\
        <table><tbody>\
        <tr><td>A</td><td>B</td></tr><tr><td>C</td><td>D</td></tr>\
        </tbody></table>\
        <p>Another paragraph.</p>
        """)
    }

    func testTableWithUnevenColumns() {
        let html = MarkdownParser().html(from: """
        | one | two |
        | three | four | five |

        | one | two |
        | three |
        """)

        XCTAssertEqual(html, """
        <table><tbody>\
        <tr><td>one</td><td>two</td><td></td></tr>\
        <tr><td>three</td><td>four</td><td>five</td></tr>\
        </tbody></table>\
        <table><tbody>\
        <tr><td>one</td><td>two</td></tr>\
        <tr><td>three</td><td></td></tr>\
        </tbody></table>
        """)
    }

    func testTableWithInternalMarkdown() {
        let html = MarkdownParser().html(from: """
        | Table  | Header     | [Link](/uri) |
        | ------ | ---------- | ------------ |
        | Some   | *emphasis* | and          |
        | `code` | in         | table        |
        """)

        XCTAssertEqual(html, """
        <table>\
        <thead>\
        <tr><th>Table</th><th>Header</th><th><a href="/uri">Link</a></th></tr>\
        </thead>\
        <tbody>\
        <tr><td>Some</td><td><em>emphasis</em></td><td>and</td></tr>\
        <tr><td><code>code</code></td><td>in</td><td>table</td></tr>\
        </tbody>\
        </table>
        """)
    }

    func testTableWithAlignment() {
        let html = MarkdownParser().html(from: """
        | Left | Center | Right |
        | :- | :-: | -:|
        | One | Two | Three |
        """)

        XCTAssertEqual(html, """
        <table>\
        <thead><tr>\
        <th align="left">Left</th><th align="center">Center</th><th align="right">Right</th>\
        </tr></thead>\
        <tbody>\
        <tr><td align="left">One</td><td align="center">Two</td><td align="right">Three</td></tr>\
        </tbody>\
        </table>
        """)
    }

    func testMissingPipeEndsTable() {
        let html = MarkdownParser().html(from: """
        | HeaderA | HeaderB |
        | ------- | ------- |
        | CellA   | CellB   |
        > Quote
        """)

        XCTAssertEqual(html, """
        <table>\
        <thead><tr><th>HeaderA</th><th>HeaderB</th></tr></thead>\
        <tbody><tr><td>CellA</td><td>CellB</td></tr></tbody>\
        </table>\
        <blockquote><p>Quote</p></blockquote>
        """)
    }

    func testHeaderNotParsedForColumnCountMismatch() {
        let html = MarkdownParser().html(from: """
        | HeaderA | HeaderB |
        | ------- |
        | CellA   | CellB |
        """)

        XCTAssertEqual(html, """
        <table><tbody>\
        <tr><td>HeaderA</td><td>HeaderB</td></tr>\
        <tr><td>-------</td><td></td></tr>\
        <tr><td>CellA</td><td>CellB</td></tr>\
        </tbody></table>
        """)
    }
}

extension TableTests {
    static var allTests: Linux.TestList<TableTests> {
        return [
            ("testTableWithoutHeader", testTableWithoutHeader),
            ("testTableWithHeader", testTableWithHeader),
            ("testTableWithUnalignedColumns", testTableWithUnalignedColumns),
            ("testTableWithOnlyHeader", testTableWithOnlyHeader),
            ("testIncompleteTable", testIncompleteTable),
            ("testInvalidTable", testInvalidTable),
            ("testTableBetweenParagraphs", testTableBetweenParagraphs),
            ("testTableWithUnevenColumns", testTableWithUnevenColumns),
            ("testTableWithInternalMarkdown", testTableWithInternalMarkdown),
            ("testTableWithAlignment", testTableWithAlignment),
            ("testMissingPipeEndsTable", testMissingPipeEndsTable),
            ("testHeaderNotParsedForColumnCountMismatch", testHeaderNotParsedForColumnCountMismatch),
        ]
    }
}
