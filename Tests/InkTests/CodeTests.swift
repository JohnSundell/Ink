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

    func testInlineCodeLeftToRight() {
        // Derived from CommonMark spec lines 5842-5846
        let html = MarkdownParser().html(from: "`hi`lo`")
        XCTAssertEqual(html, "<p><code>hi</code>lo`</p>")
    }
    
    func testCodeBlockWithJustBackticks() {
        let html = MarkdownParser().html(from: """
        ```
        code()
        block()
        ```
        """)

        XCTAssertEqual(html, "<pre><code>code()\nblock()\n</code></pre>")
    }

    func testCodeBlockWithBackticksAndLabel() {
        let html = MarkdownParser().html(from: """
        ```swift
        code()
        ```
        """)

        XCTAssertEqual(html, "<pre><code class=\"language-swift\">code()\n</code></pre>")
    }
    
    func testCodeBlockWithBackticksAndLongInfoString() {
        // Derived from CommonMark spec lines 2304-2315
        let html = MarkdownParser().html(from: """
        ````    ruby startline=3 $%@#$
        def foo(x)
          return 3
        end
        ````
        """)

        XCTAssertEqual(html, """
        <pre><code class="language-ruby">def foo(x)
          return 3
        end
        </code></pre>
        """)
    }
    
    func testCodeBlockWithSillyLanguageName() {
        // Derived from CommonMark spec lines 2318-2323
        let html = MarkdownParser().html(from:
        #####"""
        ```;
        ```
        """#####
        + "\n"
        )

        XCTAssertEqual(html, """
        <pre><code class="language-;"></code></pre>
        """)
    }
    
    func testCodeBlockWithBackticksAndLabelNeedingTrimming() {
       // there are 2 spaces after the swift label that need trimming too
       let html = MarkdownParser().html(from: """
       ``` swift  
       code()
       ```
       """)

       XCTAssertEqual(html, "<pre><code class=\"language-swift\">code()\n</code></pre>")
   }
    
    func testCodeBlockManyBackticks() {
        // there are 2 spaces after the swift label that need trimming too
        let html = MarkdownParser().html(from: """
        
        ```````````````````````````````` foo
        bar
        ````````````````````````````````
        """)

        XCTAssertEqual(html, "<pre><code class=\"language-foo\">bar\n</code></pre>")
    }
    
    func testCodeBlockSufficientBackticks() {
        // Derived from CommonMark spec lines 2046-2055
        let html = MarkdownParser().html(from: """
           ````
           aaa
           ```
           ``````
           """)
        
        XCTAssertEqual(html, #####"""
           <pre><code>aaa
           ```
           </code></pre>
           """#####)
    }
    
    func testCodeBlockFakeClosureAndFileEndingBlock() {
        // Derived from CommonMark spec lines 2046-2055
        let html = MarkdownParser().html(from: #####"""
           ````
           aaa
           ```` this is \really code \" &
           ```
           """#####)
        
        XCTAssertEqual(html, #####"""
           <pre><code>aaa
           ```` this is \really code \&quot; &amp;
           ```</code></pre>
           """#####)
    }

    func testEncodingSpecialCharactersWithinCodeBlock() {
        let html = MarkdownParser().html(from: """
        ```swift
        Generic<T>() && expression()
        ```
        """)

        XCTAssertEqual(html, """
        <pre><code class="language-swift">Generic&lt;T&gt;() &amp;&amp; expression()\n</code></pre>
        """)
    }
    
    func testEscapeBehaviorWithinCodeBlock() {
        let html = MarkdownParser().html(from:
        #####"""
        ```swift
        \< < \& & \" " \> >
        \a a \\ \` `
        ```
        """#####
        )

        XCTAssertEqual(html,
        #####"""
        <pre><code class="language-swift">\&lt; &lt; \&amp; &amp; \&quot; &quot; \&gt; &gt;
        \a a \\ \` `
        </code></pre>
        """#####
        )
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
        - Not a list\n</code></pre>
        """)
    }
    
    func testCodeBlockBetweenParagraphs() {
        // Derived from CommonMark spec lines 2251-2262
        let html = MarkdownParser().html(from: #####"""
        foo
        ```
        bar
        ```
        baz
        """#####)
        
        XCTAssertEqual(html, #####"""
        <p>foo</p><pre><code>bar
        </code></pre><p>baz</p>
        """#####)
    }
}

extension CodeTests {
    static var allTests: Linux.TestList<CodeTests> {
        return [
            ("testInlineCode", testInlineCode),
            ("testInlineCodeLeftToRight", testInlineCodeLeftToRight),
            ("testCodeBlockWithJustBackticks", testCodeBlockWithJustBackticks),
            ("testCodeBlockWithBackticksAndLabel", testCodeBlockWithBackticksAndLabel),
            ("testCodeBlockWithBackticksAndLongInfoString", testCodeBlockWithBackticksAndLongInfoString),
            ("testCodeBlockWithSillyLanguageName", testCodeBlockWithSillyLanguageName),
            ("testCodeBlockWithBackticksAndLabelNeedingTrimming", testCodeBlockWithBackticksAndLabelNeedingTrimming),
            ("testCodeBlockManyBackticks", testCodeBlockManyBackticks),
            ("testCodeBlockSufficientBackticks", testCodeBlockSufficientBackticks),
            ("testCodeBlockFakeClosureAndFileEndingBlock", testCodeBlockFakeClosureAndFileEndingBlock),
            ("testEncodingSpecialCharactersWithinCodeBlock", testEncodingSpecialCharactersWithinCodeBlock),
            ("testEscapeBehaviorWithinCodeBlock", testEscapeBehaviorWithinCodeBlock),
            ("testIgnoringFormattingWithinCodeBlock", testIgnoringFormattingWithinCodeBlock),
            ("testCodeBlockBetweenParagraphs", testCodeBlockBetweenParagraphs)
        ]
    }
}
