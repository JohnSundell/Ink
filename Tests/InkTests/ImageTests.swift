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

    func testImageWithReferenceAndAltText() {
        let html = MarkdownParser().html(from: """
        ![Alt text][url]
        [url]: swiftbysundell.com
        """)

        XCTAssertEqual(html, #"<img src="swiftbysundell.com" alt="Alt text"/>"#)
    }

    func testImageWithinParagraph() {
        let html = MarkdownParser().html(from: "Text ![](url) text")
        XCTAssertEqual(html, #"<p>Text <img src="url"/> text</p>"#)
    }

    func testImageWithSizeAttributes() {
        do {
            let html = MarkdownParser().html(from: "![](https://example/image.png width=400)")
            XCTAssertEqual(html, #"<img src="https://example/image.png" width="400"/>"#)
        }
        do {
            let html = MarkdownParser().html(from: "![](https://example/image.png width=400 height=300)")
            XCTAssertEqual(html, #"<img src="https://example/image.png" width="400" height="300"/>"#)
        }
    }
}

extension ImageTests {
    static var allTests: Linux.TestList<ImageTests> {
        return [
            ("testImageWithURL", testImageWithURL),
            ("testImageWithReference", testImageWithReference),
            ("testImageWithURLAndAltText", testImageWithURLAndAltText),
            ("testImageWithReferenceAndAltText", testImageWithReferenceAndAltText),
            ("testImageWithinParagraph", testImageWithinParagraph),
            ("testImageWithSizeAttributes", testImageWithSizeAttributes)
        ]
    }
}
