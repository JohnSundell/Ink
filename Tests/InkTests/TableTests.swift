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

        XCTAssertEqual(html, #"<table><tr><td>Swift</td><td>Apple</td></tr><tr><td>Objective-C</td><td>Tom Love and Brad Cox</td></tr></table>"#)
    }

    func testTableWithHeader() {
        let html = MarkdownParser().html(from: """
        | Language     | Creator               | Year |
        | ------------ | --------------------- | ---- |
        | Swift        | Apple                 | 2014 |
        | Objective-C  | Tom Love and Brad Cox | 1984 |
        """)

        XCTAssertEqual(html, #"<table><tr><th>Language</th><th>Creator</th><th>Year</th></tr><tr><td>Swift</td><td>Apple</td><td>2014</td></tr><tr><td>Objective-C</td><td>Tom Love and Brad Cox</td><td>1984</td></tr></table>"#)
    }

    func testTableWithUnalignedColumns() {
        let html = MarkdownParser().html(from: """
        | Language                        | Creator    | Year |
        | ------------------------------ | ----------- | ------------ |
        | Swift                    | Apple      | 2014       |
        | Objective-C                     | Tom Love and Brad Cox       | 1984        |
        """)

        XCTAssertEqual(html, #"<table><tr><th>Language</th><th>Creator</th><th>Year</th></tr><tr><td>Swift</td><td>Apple</td><td>2014</td></tr><tr><td>Objective-C</td><td>Tom Love and Brad Cox</td><td>1984</td></tr></table>"#)
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
}

extension TableTests {
    static var allTests: Linux.TestList<TableTests> {
        return [
            ("testTableWithoutHeader", testTableWithoutHeader),
            ("testTableWithHeader", testTableWithHeader),
            ("testTableWithUnalignedColumns", testTableWithUnalignedColumns),
            ("testIncompleteTable", testIncompleteTable),
            ("testInvalidTable", testInvalidTable)
        ]
    }
}
