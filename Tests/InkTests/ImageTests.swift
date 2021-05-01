/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Ink

final class ImageTests: XCTestCase {
    func testImageWithURL() {
        let html = MarkdownParser().html(from: "![](url)")
        XCTAssertEqual(html, #"<img src="url"/>"#)
    }

    func testImageWithReference() {
        let html = MarkdownParser().html(from: """
        ![][url]
        [url]: https://swiftbysundell.com
        """)

        XCTAssertEqual(html, #"<img src="https://swiftbysundell.com"/>"#)
    }

    func testImageWithURLAndAltText() {
        let html = MarkdownParser().html(from: "![Alt text](url)")
        XCTAssertEqual(html, #"<img src="url" alt="Alt text"/>"#)
    }

    func testImageWithURLAndAltTextAndTitle() {
        let html = MarkdownParser().html(from: "![Alt text](url \"Swift by Sundell\")")
        XCTAssertEqual(html, #"<img src="url" alt="Alt text" title="Swift by Sundell"/>"#)
    }

    func testImageWithReferenceAndAltText() {
        let html = MarkdownParser().html(from: """
        ![Alt text][url]
        [url]: swiftbysundell.com
        """)

        XCTAssertEqual(html, #"<img src="swiftbysundell.com" alt="Alt text"/>"#)
    }

    func testImageWithReferenceAndAltTextAndTitle() {
        let html = MarkdownParser().html(from: """
        ![Alt text][url]
        [url]: swiftbysundell.com    'Swift by Sundell'
        """)

        XCTAssertEqual(html, #"<img src="swiftbysundell.com" alt="Alt text" title="Swift by Sundell"/>"#)
    }

    func testImageWithReferenceAndAltTextAndNewlineTitle() {
        let html = MarkdownParser().html(from: """
        ![Alt text][url]
        [url]: swiftbysundell.com
              (Swift by Sundell)
        """)

        XCTAssertEqual(html, #"<img src="swiftbysundell.com" alt="Alt text" title="Swift by Sundell"/>"#)
    }

    func testImageWithinParagraph() {
        let html = MarkdownParser().html(from: "Text ![](url) text")
        XCTAssertEqual(html, #"<p>Text <img src="url"/> text</p>"#)
    }
}

extension ImageTests {
    static var allTests: Linux.TestList<ImageTests> {
        return [
            ("testImageWithURL", testImageWithURL),
            ("testImageWithReference", testImageWithReference),
            ("testImageWithURLAndAltText", testImageWithURLAndAltText),
            ("testImageWithURLAndAltTextAndTitle", testImageWithURLAndAltTextAndTitle),
            ("testImageWithReferenceAndAltText", testImageWithReferenceAndAltText),
            ("testImageWithReferenceAndAltTextAndTitle", testImageWithReferenceAndAltTextAndTitle),
            ("testImageWithReferenceAndAltTextAndNewlineTitle", testImageWithReferenceAndAltTextAndNewlineTitle),
            ("testImageWithinParagraph", testImageWithinParagraph)
        ]
    }
}
