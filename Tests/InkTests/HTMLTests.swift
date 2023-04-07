/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Ink

final class HTMLTests: XCTestCase {
    func testTopLevelHTML() {
        let html = MarkdownParser().html(from: """
        Hello

        <div>
            <span class="text">Whole wide</span>
        </div>

        World
        """)

        XCTAssertEqual(html, """
        <p>Hello</p><div>
            <span class="text">Whole wide</span>
        </div><p>World</p>
        """)
    }

    func testNestedTopLevelHTML() {
        let html = MarkdownParser().html(from: """
        <div>
            <div>Hello</div>
            <div>World</div>
        </div>
        """)

        XCTAssertEqual(html, """
        <div>
            <div>Hello</div>
            <div>World</div>
        </div>
        """)
    }

    func testTopLevelHTMLWithPreviousNewline() {
        let html = MarkdownParser().html(from: "Text\n<h2>Heading</h2>")
        XCTAssertEqual(html, "<p>Text</p><h2>Heading</h2>")
    }

    func testIgnoringFormattingWithinTopLevelHTML() {
        let html = MarkdownParser().html(from: "<div>_Hello_</div>")
        XCTAssertEqual(html, "<div>_Hello_</div>")
    }

    func testIgnoringTextFormattingWithinInlineHTML() {
        let html = MarkdownParser().html(from: "Hello <span>_World_</span>")
        XCTAssertEqual(html, "<p>Hello <span>_World_</span></p>")
    }

    func testIgnoringListsWithinInlineHTML() {
        let html = MarkdownParser().html(from: "<h2>1. Hello</h2><h2>- World</h2>")
        XCTAssertEqual(html, "<h2>1. Hello</h2><h2>- World</h2>")
    }

    func testInlineParagraphTagEndingCurrentParagraph() {
        let html = MarkdownParser().html(from: "One <p>Two</p> Three")
        XCTAssertEqual(html, "<p>One</p><p>Two</p><p>Three</p>")
    }

    func testTopLevelSelfClosingHTMLElement() {
        let html = MarkdownParser().html(from: """
        Hello

        <img src="image.png"/>

        World
        """)

        XCTAssertEqual(html, #"<p>Hello</p><img src="image.png"/><p>World</p>"#)
    }

    func testInlineSelfClosingHTMLElement() {
        let html = MarkdownParser().html(from: #"Hello <img src="image.png"/> World"#)
        XCTAssertEqual(html, #"<p>Hello <img src="image.png"/> World</p>"#)
    }

    func testTopLevelHTMLLineBreak() {
        let html = MarkdownParser().html(from: """
        Hello
        <br/>
        World
        """)

        XCTAssertEqual(html, "<p>Hello</p><br/><p>World</p>")
    }

    func testHTMLComment() {
        let html = MarkdownParser().html(from: """
        Hello
        <!-- Comment -->
        World
        """)

        XCTAssertEqual(html, "<p>Hello</p><!-- Comment --><p>World</p>")
    }

    func testHTMLEntities() {
        let html = MarkdownParser().html(from: """
        Hello &amp; welcome to &lt;Ink&gt;
        """)

        XCTAssertEqual(html, "<p>Hello &amp; welcome to &lt;Ink&gt;</p>")
    }

    func testMarkdownHeadingInsideHTML() {
        let html = MarkdownParser().html(from: """
        <div>

        ## Heading

        </div>
        """)

        XCTAssertEqual(html, "<div><h2>Heading</h2></div>")
    }

    func testMarkdownImageInsideHTML() {
        let html = MarkdownParser().html(from: """
        <div>

        ![test image](https://test.com/test.jpg)

        </div>
        """)

        XCTAssertEqual(html, "<div><img src=\"https://test.com/test.jpg\" alt=\"test image\"/></div>")
    }

    func testMarkdownListInsideHTML() {
        let html = MarkdownParser().html(from: """
        <div>

        - One
        - Two
        - Three

        </div>
        """)

        XCTAssertEqual(html, "<div><ul><li>One</li><li>Two</li><li>Three</li></ul></div>")
    }

    func testMarkdownBeforeHTML() {
        let html = MarkdownParser().html(from: """
        <div>

        # Heading1

        <h2>Heading2</h2></div>
        """)

        XCTAssertEqual(html, "<div><h1>Heading1</h1><h2>Heading2</h2></div>")
    }

    func testMarkdownAfterHTML() {
        let html = MarkdownParser().html(from: """
        <div><h2>Heading2</h2>

        # Heading1
        </div>
        """)

        XCTAssertEqual(html, "<div><h2>Heading2</h2><h1>Heading1</h1></div>")
    }


    func testMultipleMarkdownInsideHTML() {
        let html = MarkdownParser().html(from: """
        <div>

        ![](image1.jpg)
        ![](image2.jpg)

        </div>
        """)

        XCTAssertEqual(html, "<div><img src=\"image1.jpg\"/><img src=\"image2.jpg\"/></div>")
    }

    func testHTMLWithDoubleNewline() {
        let src = """
        <div>

        <h1>Heading</h1>

        </div>
        """
        let html = MarkdownParser().html(from: src)

        XCTAssertEqual(html, src)
    }

    func testUnclosedHTMLWithDoubleNewline() {
        let src = """
        <div>
        *foo*

        *bar*
        """
        let html = MarkdownParser().html(from: src)

        XCTAssertEqual(html, "<div>\n*foo*<p><em>bar</em></p>")
    }

    func testParagraphInsideHTML() {
        let html = MarkdownParser().html(from: """
        <div>

        *Emphasized* text.

        </div>
        """)
        XCTAssertEqual(html, "<div><p><em>Emphasized</em> text.</p></div>")
    }

    func testModifiersAppliedToMarkdownInsideHTML() {
        var parser = MarkdownParser()
        parser.addModifier(Modifier(target: .headings, closure: { input in return input.html+"<hr>"}))
        let html = parser.html(from: """
        <div>

        # Heading

        </div>
        """)
        XCTAssertEqual(html, "<div><h1>Heading</h1><hr></div>")
    }
}

extension HTMLTests {
    static var allTests: Linux.TestList<HTMLTests> {
        return [
            ("testTopLevelHTML", testTopLevelHTML),
            ("testNestedTopLevelHTML", testNestedTopLevelHTML),
            ("testTopLevelHTMLWithPreviousNewline", testTopLevelHTMLWithPreviousNewline),
            ("testIgnoringFormattingWithinTopLevelHTML", testIgnoringFormattingWithinTopLevelHTML),
            ("testIgnoringTextFormattingWithinInlineHTML", testIgnoringTextFormattingWithinInlineHTML),
            ("testIgnoringListsWithinInlineHTML", testIgnoringListsWithinInlineHTML),
            ("testInlineParagraphTagEndingCurrentParagraph", testInlineParagraphTagEndingCurrentParagraph),
            ("testTopLevelSelfClosingHTMLElement", testTopLevelSelfClosingHTMLElement),
            ("testInlineSelfClosingHTMLElement", testInlineSelfClosingHTMLElement),
            ("testTopLevelHTMLLineBreak", testTopLevelHTMLLineBreak),
            ("testHTMLComment", testHTMLComment),
            ("testHTMLEntities", testHTMLEntities),
            ("testMarkdownHeadingInsideHTML", testMarkdownHeadingInsideHTML),
            ("testMarkdownImageInsideHTML", testMarkdownImageInsideHTML),
            ("testMarkdownListInsideHTML", testMarkdownListInsideHTML),
            ("testMarkdownBeforeHTML", testMarkdownBeforeHTML),
            ("testMarkdownAfterHTML", testMarkdownAfterHTML),
            ("testMultipleMarkdownInsideHTML", testMultipleMarkdownInsideHTML),
            ("testHTMLWithDoubleNewline", testHTMLWithDoubleNewline),
            ("testUnclosedHTMLWithDoubleNewline", testUnclosedHTMLWithDoubleNewline),
            ("testParagraphInsideHTML", testParagraphInsideHTML),
            ("testModifiersAppliedToMarkdownInsideHTML", testModifiersAppliedToMarkdownInsideHTML),
        ]
    }
}
