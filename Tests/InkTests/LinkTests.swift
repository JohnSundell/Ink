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

    func testLinkWithReference() {
        let html = MarkdownParser().html(from: """
        [Title][url]

        [url]: swiftbysundell.com
        """)

        XCTAssertEqual(html, #"<p><a href="swiftbysundell.com">Title</a></p>"#)
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
    
   func testBackslashInURL() {
       // Derived from CommonMark spec lines 596-600
       // Backslash work in all other contexts, including URLs
       let inputString =
       #####"""
       [foo](/bar\* "ti\*tle")
       """#####
       let html = MarkdownParser().html(from: inputString)
       
       let properAnswer = #####"""
       <p><a href="/bar*" title="ti*tle">foo</a></p>
       """#####
       XCTAssertEqual(html, properAnswer)
   }
}

extension LinkTests {
    static var allTests: Linux.TestList<LinkTests> {
        return [
            ("testLinkWithURL", testLinkWithURL),
            ("testLinkWithReference", testLinkWithReference),
            ("testCaseMismatchedLinkWithReference", testCaseMismatchedLinkWithReference),
            ("testNumericLinkWithReference", testNumericLinkWithReference),
            ("testBoldLinkWithInternalMarkers", testBoldLinkWithInternalMarkers),
            ("testBoldLinkWithExternalMarkers", testBoldLinkWithExternalMarkers),
            ("testLinkWithUnderscores", testLinkWithUnderscores),
            ("testUnterminatedLink", testUnterminatedLink),
            ("testLinkWithEscapedSquareBrackets", testLinkWithEscapedSquareBrackets),
            ("testBackslashInURL", testBackslashInURL)
        ]
    }
}
