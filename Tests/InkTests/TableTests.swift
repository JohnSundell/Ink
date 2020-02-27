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
        | Swift       | Apple                 |
        | Objective-C | Tom Love and Brad Cox |
        """)

        XCTAssertEqual(html, #"<table><tbody><tr><td>Swift</td><td>Apple</td></tr><tr><td>Objective-C</td><td>Tom Love and Brad Cox</td></tr></tbody></table>"#)
    }

    func testTableWithHeader() {
        let html = MarkdownParser().html(from: """
        | Language     | Creator               | Year |
        | ------------ | --------------------- | ---- |
        | Swift        | Apple                 | 2014 |
        | Objective-C  | Tom Love and Brad Cox | 1984 |
        """)

        XCTAssertEqual(html, #"<table><thead><tr><th>Language</th><th>Creator</th><th>Year</th></tr></thead><tbody><tr><td>Swift</td><td>Apple</td><td>2014</td></tr><tr><td>Objective-C</td><td>Tom Love and Brad Cox</td><td>1984</td></tr></tbody></table>"#)
    }

    func testTableWithUnalignedColumns() {
        let html = MarkdownParser().html(from: """
        | Language                        | Creator    | Year |
        | ------------------------------ | ----------- | ------------ |
        | Swift                    | Apple      | 2014       |
        | Objective-C                     | Tom Love and Brad Cox       | 1984        |
        """)

        XCTAssertEqual(html, #"<table><thead><tr><th>Language</th><th>Creator</th><th>Year</th></tr></thead><tbody><tr><td>Swift</td><td>Apple</td><td>2014</td></tr><tr><td>Objective-C</td><td>Tom Love and Brad Cox</td><td>1984</td></tr></tbody></table>"#)
    }

    func testTableWithOnlyHeader() {
        let html = MarkdownParser().html(from: """
        | Language     | Creator               | Year |
        | ------------ | --------------------- | ---- |
        """)

        XCTAssertEqual(html, #"<table><thead><tr><th>Language</th><th>Creator</th><th>Year</th></tr></thead></table>"#)
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

        | Swift       | Apple                 |
        | Objective-C | Tom Love and Brad Cox |

        Another paragraph.
        """)

        XCTAssertEqual(html, "<p>A paragraph.</p><table><tbody><tr><td>Swift</td><td>Apple</td></tr><tr><td>Objective-C</td><td>Tom Love and Brad Cox</td></tr></tbody></table><p>Another paragraph.</p>")
    }

    func testTableWithUnevenColumns() {
        let html = MarkdownParser().html(from: """
        | one | two |
        | three | four | five |

        | one | two |
        | three |
        """)

        XCTAssertEqual(html, "<table><tbody><tr><td>one</td><td>two</td></tr><tr><td>three</td><td>four</td></tr></tbody></table><table><tbody><tr><td>one</td><td>two</td></tr><tr><td>three</td><td></td></tr></tbody></table>")
    }

    func testTableWithInternalMarkdown() {
        let html = MarkdownParser().html(from: """
        | Table  | Header     | [Link](/uri) |
        | ------ | ---------- | ------------ |
        | Some   | *emphasis* | and          |
        | `code` | in         | table        |
        """)

        XCTAssertEqual(html, #"<table><thead><tr><th>Table</th><th>Header</th><th><a href="/uri">Link</a></th></tr></thead><tbody><tr><td>Some</td><td><em>emphasis</em></td><td>and</td></tr><tr><td><code>code</code></td><td>in</td><td>table</td></tr></tbody></table>"#)
    }

    func testTableWithAlignment() {
        let html = MarkdownParser().html(from: """
        | Left | Center | Right |
        | :- | :-: | -:|
        | One | Two | Three |
        """)

        XCTAssertEqual("\n"+html, #"\#n<table><thead><tr><th align="left">Left</th><th align="center">Center</th><th align="right">Right</th></tr></thead><tbody><tr><td align="left">One</td><td align="center">Two</td><td align="right">Three</td></tr></tbody></table>"#)
    }

    func testMissingPipeEndsTable() {
        let html = MarkdownParser().html(from: """
        | abc | def |
        | --- | --- |
        | bar | baz |
        > bar
        """)

        XCTAssertEqual(html, "<table><thead><tr><th>abc</th><th>def</th></tr></thead><tbody><tr><td>bar</td><td>baz</td></tr></tbody></table><blockquote><p>bar</p></blockquote>")
    }

    func testHeaderAndDelimiterRowsMatchCount() {
        let html = MarkdownParser().html(from: """
        | abc | def |
        | --- |
        | bar |
        """)

        XCTAssertEqual(html, "<p>| abc | def | | --- | | bar |</p>")
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
            ("testHeaderAndDelimiterRowsMatchCount", testHeaderAndDelimiterRowsMatchCount),
        ]
    }
}
