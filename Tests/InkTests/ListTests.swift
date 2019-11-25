/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Ink

final class ListTests: XCTestCase {
    func testOrderedList() {
        let html = MarkdownParser().html(from: """
        1. One
        2. Two
        """)

        XCTAssertEqual(html, #"<ol><li>One</li><li>Two</li></ol>"#)
    }

    func testOrderedListWithoutIncrementedNumbers() {
        let html = MarkdownParser().html(from: """
        1. One
        3. Two
        17. Three
        """)

        XCTAssertEqual(html, "<ol><li>One</li><li>Two</li><li>Three</li></ol>")
    }

    func testOrderedListWithInvalidNumbers() {
        let html = MarkdownParser().html(from: """
        1. One
        3!. Two
        17. Three
        """)

        XCTAssertEqual(html, "<ol><li>One 3!. Two</li><li>Three</li></ol>")
    }

    func testUnorderedList() {
        let html = MarkdownParser().html(from: """
        - One
        * Two
        - Three
        """)

        XCTAssertEqual(html, "<ul><li>One</li><li>Two</li><li>Three</li></ul>")
    }

    func testUnorderedListWithMultiLineItem() {
        let html = MarkdownParser().html(from: """
        - One
        Some text
        - Two
        """)

        XCTAssertEqual(html, "<ul><li>One Some text</li><li>Two</li></ul>")
    }

    func testUnorderedListWithNestedList() {
        let html = MarkdownParser().html(from: """
        - A
        - B
            - B1
                - B11
            - B2
        """)

        let expectedComponents: [String] = [
            "<ul>",
                "<li>A</li>",
                "<li>B",
                    "<ul>",
                        "<li>B1",
                            "<ul>",
                                "<li>B11</li>",
                            "</ul>",
                        "</li>",
                        "<li>B2</li>",
                    "</ul>",
                "</li>",
            "</ul>"
        ]

        XCTAssertEqual(html, expectedComponents.joined())
    }

    func testUnorderedListWithInvalidMarker() {
        let html = MarkdownParser().html(from: """
        - One
        -Two
        - Three
        """)

        XCTAssertEqual(html, "<ul><li>One -Two</li><li>Three</li></ul>")
    }
}
