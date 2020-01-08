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

        XCTAssertEqual(html, #"<p><a href="/url">Title</a>\#n<a href="/φου">Title</a></p>"#)
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
     // A link can contain fragment identifiers and queries:
     //
     //
     // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
     // spec.txt lines 7953-7963
     func testExample509() {
         let markdownTest =
         #####"""
         [link](#fragment)
         
         [link](http://example.com#fragment)
         
         [link](http://example.com?foo=3#frag)\#####n
         """#####
     
         let html = MarkdownParser().html(from: markdownTest)
         .replacingOccurrences(of: ">\n<", with: "><")
         
       //<p><a href="#fragment">link</a></p>
       //<p><a href="http://example.com#fragment">link</a></p>
       //<p><a href="http://example.com?foo=3#frag">link</a></p>
         let normalizedCM = #####"""
         <p><a href="#fragment">link</a></p><p><a href="http://example.com#fragment">link</a></p><p><a href="http://example.com?foo=3#frag">link</a></p>
         """#####
     
         XCTAssertEqual(html,normalizedCM)
     }

    // Unicode case fold is used:
    //
    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 8381-8387
    func testExample548() {
        let markdownTest =
        #####"""
        [Толпой][Толпой] is a Russian word.
        
        [ТОЛПОЙ]: /url\#####n
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        .replacingOccurrences(of: ">\n<", with: "><")
        
      //<p><a href="/url">Толпой</a> is a Russian word.</p>
        let normalizedCM = #####"""
        <p><a href="/url">Толпой</a> is a Russian word.</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Note that a backslash before a non-escapable character is
      // just a backslash:
      //
      //
      // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
      // spec.txt lines 7969-7973
      func testExample510() {
          let markdownTest =
          #####"""
          [link](foo\bar)
          """#####
      
          let html = MarkdownParser().html(from: markdownTest)
          
          
        //<p><a href="foo%5Cbar">link</a></p>
          let normalizedCM = #####"""
          <p><a href="foo%5Cbar">link</a></p>
          """#####
      
          XCTAssertEqual(html,normalizedCM)
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
            ("testExample509", testExample509),
            ("testExample548", testExample548),
            ("testExample510", testExample510)

        ]
    }
}
