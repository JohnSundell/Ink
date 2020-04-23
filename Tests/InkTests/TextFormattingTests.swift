/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Ink
import XCTest

final class TextFormattingTests: XCTestCase {
    func testParagraph() {
        let html = MarkdownParser().html(from: "Hello, world!")
        XCTAssertEqual(html, "<p>Hello, world!</p>")
    }

    func testItalicText() {
        let html = MarkdownParser().html(from: "Hello, *world*!")
        XCTAssertEqual(html, "<p>Hello, <em>world</em>!</p>")
    }

    func testBoldText() {
        let html = MarkdownParser().html(from: "Hello, **world**!")
        XCTAssertEqual(html, "<p>Hello, <strong>world</strong>!</p>")
    }

    func testItalicBoldText() {
        let html = MarkdownParser().html(from: "Hello, ***world***!")
        XCTAssertEqual(html, "<p>Hello, <strong><em>world</em></strong>!</p>")
    }

    func testItalicBoldTextWithSeparateStartMarkers() {
        let html = MarkdownParser().html(from: "**Hello, *world***!")
        XCTAssertEqual(html, "<p><strong>Hello, <em>world</em></strong>!</p>")
    }

    func testItalicTextWithinBoldText() {
        let html = MarkdownParser().html(from: "**Hello, *world*!**")
        XCTAssertEqual(html, "<p><strong>Hello, <em>world</em>!</strong></p>")
    }

    func testBoldTextWithinItalicText() {
        let html = MarkdownParser().html(from: "*Hello, **world**!*")
        XCTAssertEqual(html, "<p><em>Hello, <strong>world</strong>!</em></p>")
    }

    func testItalicTextWithExtraLeadingMarkers() {
        let html = MarkdownParser().html(from: "**Hello*")
        XCTAssertEqual(html, "<p>*<em>Hello</em></p>")
    }

    func testBoldTextWithExtraLeadingMarkers() {
        let html = MarkdownParser().html(from: "***Hello**")
        XCTAssertEqual(html, "<p><strong>*Hello</strong></p>")
    }

    func testItalicTextWithExtraTrailingMarkers() {
        let html = MarkdownParser().html(from: "*Hello**")
        XCTAssertEqual(html, "<p><em>Hello</em>*</p>")
    }

    func testBoldTextWithExtraTrailingMarkers() {
        let html = MarkdownParser().html(from: "**Hello***")
        XCTAssertEqual(html, "<p><strong>Hello</strong>*</p>")
    }

    func testItalicBoldTextWithExtraTrailingMarkers() {
        let html = MarkdownParser().html(from: "**Hello, *world*****!")
        XCTAssertEqual(html, "<p><strong>Hello, <em>world</em></strong>**!</p>")
    }

    func testUnterminatedItalicMarker() {
        let html = MarkdownParser().html(from: "*Hello")
        XCTAssertEqual(html, "<p>*Hello</p>")
    }

    func testUnterminatedBoldMarker() {
        let html = MarkdownParser().html(from: "**Hello")
        XCTAssertEqual(html, "<p>**Hello</p>")
    }

    func testUnterminatedItalicBoldMarker() {
        let html = MarkdownParser().html(from: "***Hello")
        XCTAssertEqual(html, "<p>***Hello</p>")
    }

    func testUnterminatedItalicMarkerWithinBoldText() {
        let html = MarkdownParser().html(from: "**Hello, *world!**")
        XCTAssertEqual(html, "<p><strong>Hello, *world!</strong></p>")
    }

    func testUnterminatedBoldMarkerWithinItalicText() {
        let html = MarkdownParser().html(from: "*Hello, **world!*")
        XCTAssertEqual(html, "<p><em>Hello, **world!</em></p>")
    }

    func testStrikethroughText() {
        let html = MarkdownParser().html(from: "Hello, ~~world!~~")
        XCTAssertEqual(html, "<p>Hello, <s>world!</s></p>")
    }

    func testSingleTildeWithinStrikethroughText() {
        let html = MarkdownParser().html(from: "Hello, ~~wor~ld!~~")
        XCTAssertEqual(html, "<p>Hello, <s>wor~ld!</s></p>")
    }

    func testUnterminatedStrikethroughMarker() {
        let html = MarkdownParser().html(from: "~~Hello")
        XCTAssertEqual(html, "<p>~~Hello</p>")
    }

    func testEncodingSpecialCharacters() {
        let html = MarkdownParser().html(from: "Hello < World & >")
        XCTAssertEqual(html, "<p>Hello &lt; World &amp; &gt;</p>")
    }

    func testSingleLineBlockquote() {
        let html = MarkdownParser().html(from: "> Hello, world!")
        XCTAssertEqual(html, "<blockquote><p>Hello, world!</p></blockquote>")
    }

    func testMultiLineBlockquote() {
        let html = MarkdownParser().html(from: """
        > One
        > Two
        > Three
        """)

        XCTAssertEqual(html, "<blockquote><p>One Two Three</p></blockquote>")
    }

    func testH1InBlockquote() {
        // https://spec.commonmark.org/0.29/#block-quotes Example 198
        let html = MarkdownParser().html(from: """
            > # Foo
            > bar
            > baz
            """)
        XCTAssertEqual(html, "<blockquote><h1>Foo</h1><p>bar baz</p></blockquote>")
    }

    func testMultiParagraphBlockquote() {
        // https://spec.commonmark.org/0.29/#block-quotes Example 214
        // According to the CommonMark spec, this should produce one blockquote element
        // containing two paragraphs.
        let html = MarkdownParser().html(
            from: """
                > foo
                >
                > bar
                """)

        XCTAssertEqual(
            html,
            "<blockquote><p>foo</p><p>bar</p></blockquote>"
        )
    }

    func testMultiLineMultiParagraphBlockquote() {
        // Related to Example 214 above, but this test ensures that multi-line paragraphs
        // are preserved. Text borrowed from the swift.org homepage.
        let html = MarkdownParser().html(
            from: """
                > Welcome to the Swift community. Together we are working to build a
                > programming language to empower everyone to turn their ideas into apps
                > on any platform.
                >
                > Announced in 2014, the Swift programming language has quickly become
                > one of the fastest growing languages in history. Swift makes it easy to
                > write software that is incredibly fast and safe by design. Our goals
                > for Swift are ambitious: we want to make programming simple things
                > easy, and difficult things possible.
                """)

        XCTAssertEqual(
            html, """
            <blockquote><p>Welcome to the Swift community. Together we are working \
            to build a programming language to empower everyone to turn their ideas \
            into apps on any platform.</p><p>Announced in 2014, the Swift \
            programming language has quickly become one of the fastest growing \
            languages in history. Swift makes it easy to write software that is \
            incredibly fast and safe by design. Our goals for Swift are ambitious: \
            we want to make programming simple things easy, and difficult things \
            possible.</p></blockquote>
            """
        )
    }

    func testEscapingSymbolsWithBackslash() {
        let html = MarkdownParser().html(from: """
        \\# Not a title
        \\*Not italic\\*
        """)

        XCTAssertEqual(html, "<p># Not a title *Not italic*</p>")
    }

    func testDoubleSpacedHardLinebreak() {
        let html = MarkdownParser().html(from: "Line 1  \nLine 2")

        XCTAssertEqual(html, "<p>Line 1<br>Line 2</p>")
    }

    func testEscapedHardLinebreak() {
        let html = MarkdownParser().html(from: "Line 1\\\nLine 2")

        XCTAssertEqual(html, "<p>Line 1<br>Line 2</p>")
    }
}

extension TextFormattingTests {
    static var allTests: Linux.TestList<TextFormattingTests> {
        return [
            ("testParagraph", testParagraph),
            ("testItalicText", testItalicText),
            ("testBoldText", testBoldText),
            ("testItalicBoldText", testItalicBoldText),
            ("testItalicBoldTextWithSeparateStartMarkers", testItalicBoldTextWithSeparateStartMarkers),
            ("testItalicTextWithinBoldText", testItalicTextWithinBoldText),
            ("testBoldTextWithinItalicText", testBoldTextWithinItalicText),
            ("testItalicTextWithExtraLeadingMarkers", testItalicTextWithExtraLeadingMarkers),
            ("testBoldTextWithExtraLeadingMarkers", testBoldTextWithExtraLeadingMarkers),
            ("testItalicTextWithExtraTrailingMarkers", testItalicTextWithExtraTrailingMarkers),
            ("testBoldTextWithExtraTrailingMarkers", testBoldTextWithExtraTrailingMarkers),
            ("testItalicBoldTextWithExtraTrailingMarkers", testItalicBoldTextWithExtraTrailingMarkers),
            ("testUnterminatedItalicMarker", testUnterminatedItalicMarker),
            ("testUnterminatedBoldMarker", testUnterminatedBoldMarker),
            ("testUnterminatedItalicBoldMarker", testUnterminatedItalicBoldMarker),
            ("testUnterminatedItalicMarkerWithinBoldText", testUnterminatedItalicMarkerWithinBoldText),
            ("testUnterminatedBoldMarkerWithinItalicText", testUnterminatedBoldMarkerWithinItalicText),
            ("testStrikethroughText", testStrikethroughText),
            ("testSingleTildeWithinStrikethroughText", testSingleTildeWithinStrikethroughText),
            ("testUnterminatedStrikethroughMarker", testUnterminatedStrikethroughMarker),
            ("testEncodingSpecialCharacters", testEncodingSpecialCharacters),
            ("testSingleLineBlockquote", testSingleLineBlockquote),
            ("testMultiLineBlockquote", testMultiLineBlockquote),
            ("testMultiParagraphBlockquote", testMultiParagraphBlockquote),
            ("testMultiLineMultiParagraphBlockquote", testMultiLineMultiParagraphBlockquote),
            ("testH1InBlockquote", testH1InBlockquote),
            ("testEscapingSymbolsWithBackslash", testEscapingSymbolsWithBackslash),
            ("testDoubleSpacedHardLinebreak", testDoubleSpacedHardLinebreak),
            ("testEscapedHardLinebreak", testEscapedHardLinebreak)
        ]
    }
}
