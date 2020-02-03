/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Ink

final class LinkTests: XCTestCase {
    func testLinkWithURL() {
        let html = MarkdownParser().html(from: "[Title](url)")
        XCTAssertEqual(html, #"<p><a href="url">Title</a></p>"#)
    }

    func testLinkWithURLAndTitle() {
        let html = MarkdownParser().html(from: "[Title](url \"Swift by Sundell\")")
        XCTAssertEqual(html, #"<p><a href="url" title="Swift by Sundell">Title</a></p>"#)
    }

    func testLinkWithoutURLAndTitle() {
        let html = MarkdownParser().html(from: "[link]()")

        XCTAssertEqual(html, #"<p><a href="">link</a></p>"#)
    }

    func testLinkWithReference() {
        let html = MarkdownParser().html(from: """
        [Title][url]

        [url]: swiftbysundell.com
        """)

        XCTAssertEqual(html, #"<p><a href="swiftbysundell.com">Title</a></p>"#)
    }

    func testLinkWithReferenceAndDoubleQuoteTitle() {
        let html = MarkdownParser().html(from: """
        [Title][url]

        [url]: swiftbysundell.com "Powered by Publish"
        """)

        XCTAssertEqual(html, #"<p><a href="swiftbysundell.com" title="Powered by Publish">Title</a></p>"#)
    }

    func testLinkWithReferenceAndSingleQuoteTitle() {
        let html = MarkdownParser().html(from: """
        [Title][url]

        [url]: swiftbysundell.com  'Powered by Publish'
        """)

        XCTAssertEqual(html, #"<p><a href="swiftbysundell.com" title="Powered by Publish">Title</a></p>"#)
    }

    func testLinkWithReferenceAndParentheticalTitle() {
        let html = MarkdownParser().html(from: """
        [Title][url]

        [url]: swiftbysundell.com (Powered by Publish)
        """)

        XCTAssertEqual(html, #"<p><a href="swiftbysundell.com" title="Powered by Publish">Title</a></p>"#)
    }

    func testLinkWithReferenceAndNewlineTitle() {
        let html = MarkdownParser().html(from: """
        [Title][url]

        [url]: swiftbysundell.com
                      'Powered by Publish'
        """)

        XCTAssertEqual(html, #"<p><a href="swiftbysundell.com" title="Powered by Publish">Title</a></p>"#)
    }

    func testCaseMismatchedLinkWithReference() {
        let html = MarkdownParser().html(from: """
        [Title][Foo]
        [Title][αγω]

        [FOO]: /url
        [ΑΓΩ]: /φου
        """)

        XCTAssertEqual(html, #"<p><a href="/url">Title</a> <a href="/φου">Title</a></p>"#)
    }

    func testNumericLinkWithReference() {
        let html = MarkdownParser().html(from: """
        [1][1]

        [1]: swiftbysundell.com
        """)

        XCTAssertEqual(html, #"<p><a href="swiftbysundell.com">1</a></p>"#)
    }

    func testBoldLinkWithInternalMarkers() {
        let html = MarkdownParser().html(from: "[**Hello**](/hello)")
        XCTAssertEqual(html, #"<p><a href="/hello"><strong>Hello</strong></a></p>"#)
    }

    func testBoldLinkWithExternalMarkers() {
        let html = MarkdownParser().html(from: "**[Hello](/hello)**")
        XCTAssertEqual(html, #"<p><strong><a href="/hello">Hello</a></strong></p>"#)
    }

    func testLinkWithUnderscores() {
        let html = MarkdownParser().html(from: "[He_llo](/he_llo)")
        XCTAssertEqual(html, "<p><a href=\"/he_llo\">He_llo</a></p>")
    }

    func testUnterminatedLink() {
        let html = MarkdownParser().html(from: "[Hello]")
        XCTAssertEqual(html, "<p>[Hello]</p>")
    }

    func testLinkWithEscapedSquareBrackets() {
        let html = MarkdownParser().html(from: "[\\[Hello\\]](hello)")
        XCTAssertEqual(html, #"<p><a href="hello">[Hello]</a></p>"#)
    }

    func testLinkDestinationCannotIncludeLinkBreaks() {
        let html = MarkdownParser().html(from: """
        [link](foo
        bar)
        """)

        XCTAssertEqual(html, #"<p>[link](foo bar)</p>"#)
    }

    func testLinkReferenceTitleMustEndLine() {
        let html = MarkdownParser().html(from: """
        [foo]: /url
        "title" ok
        """)

        XCTAssertEqual(html, #"<p>"title" ok</p>"#)
    }

    func testInlineLinkHasPrecedenceOverReferenceLink() {
        let html = MarkdownParser().html(from: """
        [foo]()

        [foo]: /url1
        """)

        XCTAssertEqual(html, #"<p><a href="">foo</a></p>"#)
    }
}

extension LinkTests {
    static var allTests: Linux.TestList<LinkTests> {
        return [
            ("testLinkWithURL", testLinkWithURL),
            ("testLinkWithURLAndTitle", testLinkWithURLAndTitle),
            ("testLinkWithoutURLAndTitle", testLinkWithoutURLAndTitle),
            ("testLinkWithReference", testLinkWithReference),
            ("testLinkWithReferenceAndDoubleQuoteTitle", testLinkWithReferenceAndDoubleQuoteTitle),
            ("testLinkWithReferenceAndSingleQuoteTitle", testLinkWithReferenceAndSingleQuoteTitle),
            ("testLinkWithReferenceAndParentheticalTitle", testLinkWithReferenceAndParentheticalTitle),
            ("testLinkWithReferenceAndNewlineTitle", testLinkWithReferenceAndNewlineTitle),
            ("testCaseMismatchedLinkWithReference", testCaseMismatchedLinkWithReference),
            ("testNumericLinkWithReference", testNumericLinkWithReference),
            ("testBoldLinkWithInternalMarkers", testBoldLinkWithInternalMarkers),
            ("testBoldLinkWithExternalMarkers", testBoldLinkWithExternalMarkers),
            ("testLinkWithUnderscores", testLinkWithUnderscores),
            ("testUnterminatedLink", testUnterminatedLink),
            ("testLinkWithEscapedSquareBrackets", testLinkWithEscapedSquareBrackets),
            ("testLinkDestinationCannotIncludeLinkBreaks", testLinkDestinationCannotIncludeLinkBreaks),
            ("testLinkReferenceTitleMustEndLine", testLinkReferenceTitleMustEndLine),
            ("testInlineLinkHasPrecedenceOverReferenceLink", testInlineLinkHasPrecedenceOverReferenceLink)
        ]
    }
}
