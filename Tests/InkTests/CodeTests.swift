/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Ink

final class CodeTests: XCTestCase {
    func testInlineCode() {
        let html = MarkdownParser().html(from: "Hello `inline.code()`")
        XCTAssertEqual(html, "<p>Hello <code>inline.code()</code></p>")
    }

    func testCodeBlockWithJustBackticks() {
        let html = MarkdownParser().html(from: """
        ```
        code()
        block()
        ```
        """)

        XCTAssertEqual(html, "<pre><code>code()\nblock()</code></pre>")
    }

    func testCodeBlockWithBackticksAndLabel() {
        let html = MarkdownParser().html(from: """
        ```swift
        code()
        ```
        """)

        XCTAssertEqual(html, "<pre><code class=\"swift\">code()</code></pre>")
    }
    
    func testCodeBlockWithBackticksAndLabelNeedingTrimming() {
           let html = MarkdownParser().html(from: """
           ``` swift
           code()
           ```
           """)

           XCTAssertEqual(html, "<pre><code class=\"swift\">code()</code></pre>")
       }
        
    func testEncodingSpecialCharactersWithinCodeBlock() {
        let html = MarkdownParser().html(from: """
        ```swift
        Generic<T>() && expression()
        ```
        """)

        XCTAssertEqual(html, """
        <pre><code class="swift">Generic&lt;T&gt;() &amp;&amp; expression()</code></pre>
        """)
    }

    func testIgnoringFormattingWithinCodeBlock() {
        let html = MarkdownParser().html(from: """
        ```
        # Not A Header
        return View()
        - Not a list
        ```
        """)

        XCTAssertEqual(html, """
        <pre><code># Not A Header
        return View()
        - Not a list</code></pre>
        """)
    }
}

extension CodeTests {
    static var allTests: [(String, TestClosure<CodeTests>)] {
        return [
            ("testInlineCode", testInlineCode),
            ("testCodeBlockWithJustBackticks", testCodeBlockWithJustBackticks),
            ("testCodeBlockWithBackticksAndLabel", testCodeBlockWithBackticksAndLabel),
            ("testCodeBlockWithBackticksAndLabelNeedingTrimming", testCodeBlockWithBackticksAndLabelNeedingTrimming),
            ("testEncodingSpecialCharactersWithinCodeBlock", testEncodingSpecialCharactersWithinCodeBlock),
            ("testIgnoringFormattingWithinCodeBlock", testIgnoringFormattingWithinCodeBlock)
        ]
    }
}
