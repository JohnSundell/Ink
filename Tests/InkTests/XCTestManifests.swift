/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CodeTests.allTests),
        testCase(HeadingTests.allTests),
        testCase(HorizontalLineTests.allTests),
        testCase(HTMLTests.allTests),
        testCase(ImageTests.allTests),
        testCase(LinkTests.allTests),
        testCase(ListTests.allTests),
        testCase(MetadataTests.allTests),
        testCase(ModifierTests.allTests),
        testCase(TextFormattingTests.allTests)
    ]
}
#endif
