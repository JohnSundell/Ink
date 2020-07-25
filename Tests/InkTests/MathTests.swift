/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Ink

final class MathTests: XCTestCase {
    func testInlineMath() {
        let html = MarkdownParser().html(from: #"\(Hello \Latex\)"#)
        XCTAssertEqual(html, #"<p><span class="math inline">Hello \Latex</span></p>"#)
    }
    
    func testDisplayMath() {
        let html = MarkdownParser().html(from: #"\[Hello \Latex\]"#)
        XCTAssertEqual(html, #"<p><span class="math display">Hello \Latex</span></p>"#)
    }
    
    func testMathWithEscape() {
        let html = MarkdownParser().html(from: #"Asterix \* and \(Hello \Latex\)"#)
        XCTAssertEqual(html, #"<p>Asterix * and <span class="math inline">Hello \Latex</span></p>"#)
    }
}

extension MathTests {
    static var allTests: Linux.TestList<MathTests> {
        return [
            ("testInlineMath", testInlineMath),
            ("testDisplayMath", testDisplayMath),
            ("testMathWithEscape", testMathWithEscape),
        ]
    }
}
