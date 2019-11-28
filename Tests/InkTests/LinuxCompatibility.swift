/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest

public enum Linux {}

public extension Linux {
    typealias TestCase = (type: XCTestCase.Type, manifest: TestManifest)
    typealias TestManifest = [(name: String, runner: TestRunner)]
    typealias TestRunner = (XCTestCase) throws -> Void
    typealias TestList<T: XCTestCase> = [(name: String, test: Test<T>)]
    typealias Test<T: XCTestCase> = (T) -> () throws -> Void
}

internal extension Linux {
    static func makeTestCase<T: XCTestCase>(using list: TestList<T>) -> TestCase {
        let manifest: TestManifest = list.map { name, function in
            (name, { type in
                try function(type as! T)()
            })
        }

        return (T.self, manifest)
    }
}

#if canImport(ObjectiveC)
internal final class LinuxVerificationTests: XCTestCase {
    func testAllTestsRunOnLinux() {
        for testCase in allTests() {
            let suite = testCase.type.defaultTestSuite

            let testNames: [String] = suite.tests.map { test in
                let components = test.name.components(separatedBy: .whitespaces)
                return components[1].replacingOccurrences(of: "]", with: "")
            }

            let linuxTestNames = Set(testCase.manifest.map { $0.name })

            for name in testNames {
                if !linuxTestNames.contains(name) {
                    XCTFail("""
                    \(testCase.type).\(name) does not run on Linux.
                    Please add it to \(testCase.type).allTests.
                    """)
                }
            }
        }
    }
}
#endif
