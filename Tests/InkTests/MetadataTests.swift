/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Ink

final class MetadataTests: XCTestCase {
    func testParsingMetadata() {
        let markdown = MarkdownParser().parse("""
        ---
        a: 1
        b : 2
        ---
        # Title
        """)

        XCTAssertEqual(markdown.metadata, [
            "a": "1",
            "b": "2"
        ])

        XCTAssertEqual(markdown.html, "<h1>Title</h1>")
    }

    func testDiscardingEmptyMetadataValues() {
        let markdown = MarkdownParser().parse("""
        ---
        a: 1
        b:
        c: 2
        ---
        # Title
        """)

        XCTAssertEqual(markdown.metadata, [
            "a": "1",
            "c": "2"
        ])

        XCTAssertEqual(markdown.html, "<h1>Title</h1>")
    }

    func testMergingOrphanMetadataValueIntoPreviousOne() {
        let markdown = MarkdownParser().parse("""
        ---
        a: 1
        b
        ---
        # Title
        """)

        XCTAssertEqual(markdown.metadata, ["a": "1 b"])
        XCTAssertEqual(markdown.html, "<h1>Title</h1>")
    }

    func testMissingMetadata() {
        let markdown = MarkdownParser().parse("""
        ---
        ---
        # Title
        """)

        XCTAssertEqual(markdown.metadata, [:])
        XCTAssertEqual(markdown.html, "<h1>Title</h1>")
    }
}
