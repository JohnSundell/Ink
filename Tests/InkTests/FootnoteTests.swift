/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Ink

final class FootnoteTests: XCTestCase {
    func testFootnote() {
        let html = MarkdownParser().html(from: """
                                               an interesting point[^1]
                                               
                                               [^1]: an interesting aside
                                               """)

        XCTAssertEqual(html, """
                             <p>an interesting point<sup id="fnref:1"><a href="#fn:1">1</a></sup></p><ol><li id="fn:1"><p>an interesting aside<a href="#fnref:1">↩</a></p></li></ol>
                             """)
    }

    func testLongNameFootnote() {
        let html = MarkdownParser().html(from: """
                                               an interesting point[^hello]
                                               
                                               [^hello]: an interesting aside
                                               """)

        XCTAssertEqual(html, """
                             <p>an interesting point<sup id="fnref:1"><a href="#fn:1">1</a></sup></p><ol><li id="fn:1"><p>an interesting aside<a href="#fnref:1">↩</a></p></li></ol>
                             """)
    }

    func testInlineFootnote() {
        let html = MarkdownParser().html(from: "an interesting point[^an interesting aside]")

        XCTAssertEqual(html, """
                             <p>an interesting point<sup id="fnref:1"><a href="#fn:1">1</a></sup></p><ol><li id="fn:1"><p>an interesting aside<a href="#fnref:1">↩</a></p></li></ol>
                             """)
    }

    func testFootnoteWithLink() {
        let html = MarkdownParser().html(from: """
                                               an interesting point[^1]
                                               
                                               [^1]: an interesting aside about [Example](http://example.com)
                                               """)

        XCTAssertEqual(html, """
                             <p>an interesting point<sup id="fnref:1"><a href="#fn:1">1</a></sup></p><ol><li id="fn:1"><p>an interesting aside about <a href="http://example.com">Example</a><a href="#fnref:1">↩</a></p></li></ol>
                             """)
    }
}

extension FootnoteTests {
    static var allTests: Linux.TestList<FootnoteTests> {
        return [
            ("testFootnote", testFootnote),
            ("testLongNameFootnote", testLongNameFootnote),
            ("testInlineFootnote", testInlineFootnote),
            ("testFootnoteWithLink", testFootnoteWithLink),
        ]
    }
}
