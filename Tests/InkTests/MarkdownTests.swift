/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Ink

final class MarkdownTests: XCTestCase {
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

    func testMetadataModifiers() {
        let parser = MarkdownParser(modifiers: [
            Modifier(target: .metadataKeys) { key, _ in
                "ModifiedKey-" + key
            },
            Modifier(target: .metadataValues) { value, _ in
                "ModifiedValue-" + value
            }
        ])

        let markdown = parser.parse("""
        ---
        keyA: valueA
        keyB: valueB
        ---
        """)

        XCTAssertEqual(markdown.metadata, [
            "ModifiedKey-keyA" : "ModifiedValue-valueA",
            "ModifiedKey-keyB" : "ModifiedValue-valueB"
        ])
    }

    func testPlainTextTitle() {
        let markdown = MarkdownParser().parse("""
        # Hello, world!
        """)

        XCTAssertEqual(markdown.title, "Hello, world!")
    }

    func testRemovingTrailingMarkersFromTitle() {
        let markdown = MarkdownParser().parse("""
        # Hello, world! ####
        """)

        XCTAssertEqual(markdown.title, "Hello, world!")
    }

    func testConvertingFormattedTitleTextToPlainText() {
        let markdown = MarkdownParser().parse("""
        # *Italic* **Bold** [Link](url) ![Image](url) `Code`
        """)

        XCTAssertEqual(markdown.title, "Italic Bold Link Image Code")
    }

    func testTreatingFirstHeadingAsTitle() {
        let markdown = MarkdownParser().parse("""
        # Title 1
        # Title 2
        ## Title 3
        """)

        XCTAssertEqual(markdown.title, "Title 1")
    }

    func testOverridingTitle() {
        var markdown = MarkdownParser().parse("# Title")
        markdown.title = "Title 2"
        XCTAssertEqual(markdown.title, "Title 2")
    }
}

extension MarkdownTests {
    static var allTests: Linux.TestList<MarkdownTests> {
        return [
            ("testParsingMetadata", testParsingMetadata),
            ("testDiscardingEmptyMetadataValues", testDiscardingEmptyMetadataValues),
            ("testMergingOrphanMetadataValueIntoPreviousOne", testMergingOrphanMetadataValueIntoPreviousOne),
            ("testMissingMetadata", testMissingMetadata),
            ("testMetadataModifiers", testMetadataModifiers),
            ("testPlainTextTitle", testPlainTextTitle),
            ("testRemovingTrailingMarkersFromTitle", testRemovingTrailingMarkersFromTitle),
            ("testConvertingFormattedTitleTextToPlainText", testConvertingFormattedTitleTextToPlainText),
            ("testTreatingFirstHeadingAsTitle", testTreatingFirstHeadingAsTitle),
            ("testOverridingTitle", testOverridingTitle)
        ]
    }
}
