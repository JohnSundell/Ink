/**
*  Ink
*  Copyright (c) Steve Hume 2019
*  MIT license, see LICENSE file for details
These tests are extracted from https://spec.commonmark.org/0.29/
title: CommonMark Spec
author: John MacFarlane
version: 0.29
date: '2019-04-06'
license: '[CC-BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0
*/

import XCTest
import Ink

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
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5674-5682
    func testExample311() {
        var markdownTest =
        #####"""
        &nbsp; &amp; &copy; &AElig; &Dcaron;
        &frac34; &HilbertSpace; &DifferentialD;
        &ClockwiseContourIntegral; &ngE;
        """#####
        markdownTest = markdownTest + "\n"
    
        let html = MarkdownParser().html(from: markdownTest)
        
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
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5693-5697
    func testExample312() {
        var markdownTest =
        #####"""
        &#35; &#1234; &#992; &#0;
        """#####
        markdownTest = markdownTest + "\n"
    
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
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5706-5710
    func testExample313() {
        var markdownTest =
        #####"""
        &#X22; &#XD06; &#xcab;
        """#####
        markdownTest = markdownTest + "\n"
    
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
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5715-5725
    func testExample314() {
        var markdownTest =
        #####"""
        &nbsp &x; &#; &#x;
        &#987654321;
        &#abcdef0;
        &ThisIsNotDefined; &hi?;
        """#####
        markdownTest = markdownTest + "\n"
    
        let html = MarkdownParser().html(from: markdownTest)
        
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
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5732-5736
    func testExample315() {
        var markdownTest =
        #####"""
        &copy
        """#####
        markdownTest = markdownTest + "\n"
    
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
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5742-5746
    func testExample316() {
        var markdownTest =
        #####"""
        &MadeUpEntity;
        """#####
        markdownTest = markdownTest + "\n"
    
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
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5753-5757
    func testExample317() {
        var markdownTest =
        #####"""
        <a href="&ouml;&ouml;.html">
        """#####
        markdownTest = markdownTest + "\n"
    
        let html = MarkdownParser().html(from: markdownTest)
        
      //<a href="&ouml;&ouml;.html">
        let normalizedCM = #####"""
        <a href="&ouml;&ouml;.html">
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //     
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5760-5764
    func testExample318() {
        var markdownTest =
        #####"""
        [foo](/f&ouml;&ouml; "f&ouml;&ouml;")
        """#####
        markdownTest = markdownTest + "\n"
    
        let html = MarkdownParser().html(from: markdownTest)
        
      //<p><a href="/f%C3%B6%C3%B6" title="föö">foo</a></p>
        let normalizedCM = #####"""
        <p><a href="/f%C3%B6%C3%B6" title="föö">foo</a></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //     
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5767-5773
    func testExample319() {
        var markdownTest =
        #####"""
        [foo]
        
        [foo]: /f&ouml;&ouml; "f&ouml;&ouml;"
        """#####
        markdownTest = markdownTest + "\n"
    
        let html = MarkdownParser().html(from: markdownTest)
        
      //<p><a href="/f%C3%B6%C3%B6" title="föö">foo</a></p>
        let normalizedCM = #####"""
        <p><a href="/f%C3%B6%C3%B6" title="föö">foo</a></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //     
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5776-5783
    func testExample320() {
        var markdownTest =
        #####"""
        ``` f&ouml;&ouml;
        foo
        ```
        """#####
        markdownTest = markdownTest + "\n"
    
        let html = MarkdownParser().html(from: markdownTest)
        
      //<pre><code class="language-föö">foo
      //</code></pre>
        let normalizedCM = #####"""
        <pre><code class="language-föö">foo
        </code></pre>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Entity and numeric character references are treated as literal
    // text in code spans and code blocks:
    // 
    //     
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5789-5793
    func testExample321() {
        var markdownTest =
        #####"""
        `f&ouml;&ouml;`
        """#####
        markdownTest = markdownTest + "\n"
    
        let html = MarkdownParser().html(from: markdownTest)
        
      //<p><code>f&amp;ouml;&amp;ouml;</code></p>
        let normalizedCM = #####"""
        <p><code>f&amp;ouml;&amp;ouml;</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //     
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5796-5801
    func testExample322() {
        var markdownTest =
        #####"""
            f&ouml;f&ouml;
        """#####
        markdownTest = markdownTest + "\n"
    
        let html = MarkdownParser().html(from: markdownTest)
        
      //<pre><code>f&amp;ouml;f&amp;ouml;
      //</code></pre>
        let normalizedCM = #####"""
        <pre><code>f&amp;ouml;f&amp;ouml;
        </code></pre>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Entity and numeric character references cannot be used
    // in place of symbols indicating structure in CommonMark
    // documents.
    // 
    //     
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5808-5814
    func testExample323() {
        var markdownTest =
        #####"""
        &#42;foo&#42;
        *foo*
        """#####
        markdownTest = markdownTest + "\n"
    
        let html = MarkdownParser().html(from: markdownTest)
        
      //<p>*foo*
      //<em>foo</em></p>
        let normalizedCM = #####"""
        <p>*foo* <em>foo</em></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //     
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5816-5825
    func testExample324() {
        var markdownTest =
        #####"""
        &#42; foo
        
        * foo
        """#####
        markdownTest = markdownTest + "\n"
    
        let html = MarkdownParser().html(from: markdownTest)
        
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
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5827-5833
    func testExample325() {
        var markdownTest =
        #####"""
        foo&#10;&#10;bar
        """#####
        markdownTest = markdownTest + "\n"
    
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
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5835-5839
    func testExample326() {
        var markdownTest =
        #####"""
        &#9;foo
        """#####
        markdownTest = markdownTest + "\n"
    
        let html = MarkdownParser().html(from: markdownTest)
        
      //<p>	foo</p>
        let normalizedCM = #####"""
        <p>	foo</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //     
    // https://github.com/commonmark/commonmark-spec
    // spec.txt lines 5842-5846
    func testExample327() {
        var markdownTest =
        #####"""
        [a](url &quot;tit&quot;)
        """#####
        markdownTest = markdownTest + "\n"
    
        let html = MarkdownParser().html(from: markdownTest)
        
      //<p>[a](url &quot;tit&quot;)</p>
        let normalizedCM = #####"""
        <p>[a](url &quot;tit&quot;)</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

}

extension EntityAndNumericCharacterReferencesTests {
    static var allTests: Linux.TestList<EntityAndNumericCharacterReferencesTests> {
        return [
        ("testExample311", testExample311),
        ("testExample312", testExample312),
        ("testExample313", testExample313),
        ("testExample314", testExample314),
        ("testExample315", testExample315),
        ("testExample316", testExample316),
        ("testExample317", testExample317),
        ("testExample318", testExample318),
        ("testExample319", testExample319),
        ("testExample320", testExample320),
        ("testExample321", testExample321),
        ("testExample322", testExample322),
        ("testExample323", testExample323),
        ("testExample324", testExample324),
        ("testExample325", testExample325),
        ("testExample326", testExample326),
        ("testExample327", testExample327)
        ]
    }
}