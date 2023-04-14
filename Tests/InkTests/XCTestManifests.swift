/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest

public func allTests() -> [Linux.TestCase] {
    return [
        Linux.makeTestCase(using: CodeTests.allTests),
        Linux.makeTestCase(using: HeadingTests.allTests),
        Linux.makeTestCase(using: HorizontalLineTests.allTests),
        Linux.makeTestCase(using: HTMLTests.allTests),
        Linux.makeTestCase(using: ImageTests.allTests),
        Linux.makeTestCase(using: LinkTests.allTests),
        Linux.makeTestCase(using: ListTests.allTests),
        Linux.makeTestCase(using: MarkdownTests.allTests),
        Linux.makeTestCase(using: ModifierTests.allTests),
        Linux.makeTestCase(using: TableTests.allTests),
        Linux.makeTestCase(using: TextFormattingTests.allTests),
        Linux.makeTestCase(using: MathTests.allTests)
    ]
}
