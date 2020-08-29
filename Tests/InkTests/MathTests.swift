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
    func testDisplayMultiLineProgression() {
        let html = MarkdownParser().html(from: #"""
            \[\begin{aligned}
                y&=\left(x-r\right)\left(x-s\right)\\
                y&=\left(x-\left(-7\right)\right)\left(x-\left(-2\right)\right)\\
                y&=\left(x+7\right)\left(x+2\right)\\
                y&=x^2+9x+14\\
                y&=x^2+bx+c\\
            \end{aligned}\]
            """#)
        print(html)
        XCTAssertEqual(html, #"""
            <p><span class="math display">\begin{aligned} y&amp;=\left(x-r\right)\left(x-s\right)\\ y&amp;=\left(x-\left(-7\right)\right)\left(x-\left(-2\right)\right)\\ y&amp;=\left(x+7\right)\left(x+2\right)\\ y&amp;=x^2+9x+14\\ y&amp;=x^2+bx+c\\ \end{aligned}</span></p>
            """#)
    }
    
    func testDisplayMultilineWithParagraph() {
        let html = MarkdownParser().html(from: #"""
            We can write a vector in a Hilbert space as a sum of basis and projection coefficients \[
                \begin{aligned}
                    \left\vert\psi\right\rangle &= \sum_iC_i\left\vert\varphi_i\right\rangle\\
                    &=\left\langle\varphi_i\vert\psi\right\rangle \left\vert\varphi_i\right\rangle
                \end{aligned}
                \] as above.
            """#)
        XCTAssertEqual(html, #"""
            <p>We can write a vector in a Hilbert space as a sum of basis and projection coefficients <span class="math display">\begin{aligned} \left\vert\psi\right\rangle &amp;= \sum_iC_i\left\vert\varphi_i\right\rangle\\ &amp;=\left\langle\varphi_i\vert\psi\right\rangle \left\vert\varphi_i\right\rangle \end{aligned}</span> as above.</p>
            """#)
    }
}

extension MathTests {
    static var allTests: Linux.TestList<MathTests> {
        return [
            ("testInlineMath", testInlineMath),
            ("testDisplayMath", testDisplayMath),
            ("testMathWithEscape", testMathWithEscape),
            ("testDisplayMultiLineProgression", testDisplayMultiLineProgression),
            ("testDisplayMultilineWithParagraph", testDisplayMultilineWithParagraph),
        ]
    }
}
