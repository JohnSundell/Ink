/**
*  Ink
*  Copyright (c) Steve Hume 2019
*  MIT license, see LICENSE file for details
---
title: GitHub Flavored Markdown Spec
version: 0.29
date: '2019-04-06'
license: '[CC-BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/)'
...
*/

import XCTest
import Ink
import Foundation

final class EntityAndNumericCharacterReferencesTests: XCTestCase {

    // ## Entity and numeric character references
    //
    // Valid HTML entity references and numeric character references
    // can be used in place of the corresponding Unicode character,
    // with the following exceptions:
    //
    // - Entity and character references are not recognized in code
    //   blocks and code spans.
    //
    // - Entity and character references cannot stand in place of
    //   special characters that define structural elements in
    //   CommonMark.  For example, although `&#42;` can be used
    //   in place of a literal `*` character, `&#42;` cannot replace
    //   `*` in emphasis delimiters, bullet list markers, or thematic
    //   breaks.
    //
    // Conforming CommonMark parsers need not store information about
    // whether a particular character was represented in the source
    // using a Unicode character or an entity reference.
    //
    // [Entity references](@) consist of `&` + any of the valid
    // HTML5 entity names + `;`. The
    // document <https://html.spec.whatwg.org/multipage/entities.json>
    // is used as an authoritative source for the valid entity
    // references and their corresponding code points.
    //
    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 5955-5963
    func testExample321() {
        let markdownTest =
        #####"""
        &nbsp; &amp; &copy; &AElig; &Dcaron;
        &frac34; &HilbertSpace; &DifferentialD;
        &ClockwiseContourIntegral; &ngE;\#####n
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        .replacingOccurrences(of: ">\n<", with: "><")
        
      //<p>  &amp; © Æ Ď
      //¾ ℋ ⅆ
      //∲ ≧̸</p>
        let normalizedCM = #####"""
        <p>  &amp; © Æ Ď ¾ ℋ ⅆ ∲ ≧̸</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // [Decimal numeric character
    // references](@)
    // consist of `&#` + a string of 1--7 arabic digits + `;`. A
    // numeric character reference is parsed as the corresponding
    // Unicode character. Invalid Unicode code points will be replaced by
    // the REPLACEMENT CHARACTER (`U+FFFD`).  For security reasons,
    // the code point `U+0000` will also be replaced by `U+FFFD`.
    //
    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 5974-5978
    func testExample322() {
        let markdownTest =
        #####"""
        &#35; &#1234; &#992; &#0;
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p># Ӓ Ϡ �</p>
        let normalizedCM = #####"""
        <p># Ӓ Ϡ �</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // [Hexadecimal numeric character
    // references](@) consist of `&#` +
    // either `X` or `x` + a string of 1-6 hexadecimal digits + `;`.
    // They too are parsed as the corresponding Unicode character (this
    // time specified with a hexadecimal numeral instead of decimal).
    //
    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 5987-5991
    func testExample323() {
        let markdownTest =
        #####"""
        &#X22; &#XD06; &#xcab;
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p>&quot; ആ ಫ</p>
        let normalizedCM = #####"""
        <p>&quot; ആ ಫ</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Here are some nonentities:
    //
    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 5996-6006
    func testExample324() {
        let markdownTest =
        #####"""
        &nbsp &x; &#; &#x;
        &#987654321;
        &#abcdef0;
        &ThisIsNotDefined; &hi?;\#####n
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        .replacingOccurrences(of: ">\n<", with: "><")
        
      //<p>&amp;nbsp &amp;x; &amp;#; &amp;#x;
      //&amp;#987654321;
      //&amp;#abcdef0;
      //&amp;ThisIsNotDefined; &amp;hi?;</p>
        let normalizedCM = #####"""
        <p>&amp;nbsp &amp;x; &amp;#; &amp;#x; &amp;#987654321; &amp;#abcdef0; &amp;ThisIsNotDefined; &amp;hi?;</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Although HTML5 does accept some entity references
    // without a trailing semicolon (such as `&copy`), these are not
    // recognized here, because it makes the grammar too ambiguous:
    //
    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6013-6017
    func testExample325() {
        let markdownTest =
        #####"""
        &copy
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p>&amp;copy</p>
        let normalizedCM = #####"""
        <p>&amp;copy</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Strings that are not on the list of HTML5 named entities are not
    // recognized as entity references either:
    //
    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6023-6027
    func testExample326() {
        let markdownTest =
        #####"""
        &MadeUpEntity;
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p>&amp;MadeUpEntity;</p>
        let normalizedCM = #####"""
        <p>&amp;MadeUpEntity;</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Entity and numeric character references are recognized in any
    // context besides code spans or code blocks, including
    // URLs, [link titles], and [fenced code block][] [info strings]:
    //
    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6034-6038
    func testExample327() {
        let markdownTest =
        #####"""
        <a href="&ouml;&ouml;.html">
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<a href="&ouml;&ouml;.html">
        let normalizedCM = #####"""
        <a href="&ouml;&ouml;.html">
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6041-6045
    func testExample328() {
        let markdownTest =
        #####"""
        [foo](/f&ouml;&ouml; "f&ouml;&ouml;")
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><a href="/f%C3%B6%C3%B6" title="föö">foo</a></p>
        let normalizedCM = #####"""
        <p><a href="/f%C3%B6%C3%B6" title="föö">foo</a></p>
        """#####
    // Change this to XCTAssertEqual when link titles and URL escaping done
        XCTAssertNotEqual(html,normalizedCM)
    }

    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6048-6054
    func testExample329() {
        let markdownTest =
        #####"""
        [foo]
        
        [foo]: /f&ouml;&ouml; "f&ouml;&ouml;"\#####n
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        .replacingOccurrences(of: ">\n<", with: "><")
        
      //<p><a href="/f%C3%B6%C3%B6" title="föö">foo</a></p>
        let normalizedCM = #####"""
        <p><a href="/f%C3%B6%C3%B6" title="föö">foo</a></p>
        """#####
        // Change this to XCTAssertEqual when link titles and URL escaping done
        XCTAssertNotEqual(html,normalizedCM)
    }

    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6057-6064
    func testExample330() {
        let markdownTest =
        #####"""
        ``` f&ouml;&ouml;
        foo
        ```\#####n
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        .replacingOccurrences(of: ">\n<", with: "><")
        
      //<pre><code class="language-föö">foo
      //</code></pre>
        let normalizedCM = #####"""
        <pre><code class="language-föö">foo
        </code></pre>
        """#####
     // Change this to XCTAssertEqual when backslashescapes merge complete
        XCTAssertNotEqual(html,normalizedCM)

    }

    // Entity and numeric character references are treated as literal
    // text in code spans and code blocks:
    //
    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6070-6074
    func testExample331() {
        let markdownTest =
        #####"""
        `f&ouml;&ouml;`
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><code>f&amp;ouml;&amp;ouml;</code></p>
        let normalizedCM = #####"""
        <p><code>f&amp;ouml;&amp;ouml;</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6077-6082
    func testExample332() {
        let markdownTest =
        #####"""
            f&ouml;f&ouml;
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<pre><code>f&amp;ouml;f&amp;ouml;
      //</code></pre>
        let normalizedCM = #####"""
        <pre><code>f&amp;ouml;f&amp;ouml;
        </code></pre>
        """#####
      // Change this to XCTAssertEqual when indented code blocks implemented
       XCTAssertNotEqual(html,normalizedCM)

    }

    // Entity and numeric character references cannot be used
    // in place of symbols indicating structure in CommonMark
    // documents.
    //
    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6089-6095
    func testExample333() {
        let markdownTest =
        #####"""
        &#42;foo&#42;
        *foo*\#####n
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        .replacingOccurrences(of: ">\n<", with: "><")
        
      //<p>*foo*
      //<em>foo</em></p>
        let normalizedCM = #####"""
        <p>*foo* <em>foo</em></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6097-6106
    func testExample334() {
        let markdownTest =
        #####"""
        &#42; foo
        
        * foo\#####n
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        .replacingOccurrences(of: ">\n<", with: "><")
        
      //<p>* foo</p>
      //<ul>
      //<li>foo</li>
      //</ul>
        let normalizedCM = #####"""
        <p>* foo</p><ul><li>foo</li></ul>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6108-6114
    func testExample335() {
        let markdownTest =
        #####"""
        foo&#10;&#10;bar
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p>foo
      //
      //bar</p>
        let normalizedCM = #####"""
        <p>foo
        
        bar</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6116-6120
    func testExample336() {
        let markdownTest =
        #####"""
        &#9;foo
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p>    foo</p>
        let normalizedCM = #####"""
        <p>\#####tfoo</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6123-6127
    func testExample337() {
        let markdownTest =
        #####"""
        [a](url &quot;tit&quot;)
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p>[a](url &quot;tit&quot;)</p>
        let normalizedCM = #####"""
        <p>[a](url &quot;tit&quot;)</p>
        """#####
    
    // Change this to XCTAssertEqual when link titles are done
        XCTAssertNotEqual(html,normalizedCM)
        
    }
    
    func testObscureCasesForCodeCoverage() {
         let markdownTest =
         #####"""
         &#34; &fjlig; &ThickSpace;
         &#⅚;  &#f;
         &#x0; &#xD800;
         &asuperlongtextvaluetokeeptheparserfromconsumingalltheinput;
         """#####
         
         let html = MarkdownParser().html(from: markdownTest)
         
         //<p>[a](url &quot;tit&quot;)</p>
         let normalizedCM = #####"""
            <p>&quot; fj    &amp;#⅚; &amp;#f; � &amp;#xD800; &amp;asuperlongtextvaluetokeeptheparserfromconsumingalltheinput;</p>
            """#####
         // Change this to XCTAssertEqual when link titles are done
         XCTAssertEqual(html,normalizedCM)
     }

}

extension EntityAndNumericCharacterReferencesTests {
    static var allTests: Linux.TestList<EntityAndNumericCharacterReferencesTests> {
        return [
        ("testExample321", testExample321),
        ("testExample322", testExample322),
        ("testExample323", testExample323),
        ("testExample324", testExample324),
        ("testExample325", testExample325),
        ("testExample326", testExample326),
        ("testExample327", testExample327),
        ("testExample328", testExample328),
        ("testExample329", testExample329),
        ("testExample330", testExample330),
        ("testExample331", testExample331),
        ("testExample332", testExample332),
        ("testExample333", testExample333),
        ("testExample334", testExample334),
        ("testExample335", testExample335),
        ("testExample336", testExample336),
        ("testExample337", testExample337),
        ("testObscureCasesForCodeCoverage", testObscureCasesForCodeCoverage)
        ]
    }
}
