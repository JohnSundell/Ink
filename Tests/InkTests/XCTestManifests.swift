/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(InkTests.allTests),
        testCase(HeadingTests.allTests),
        testCase(HTMLTests.allTests),
        testCase(ImageTests.allTests),
        testCase(LinkTests.allTests),
        testCase(TextFormattingTests.allTests)
    ]
}
#endif
