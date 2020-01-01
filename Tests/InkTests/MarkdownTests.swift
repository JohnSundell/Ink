/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import XCTest
import Ink

final class MarkdownTests: XCTestCase {
    func testParsingMetadata() {
        let markdown = MarkdownParser().parse("""
        ---
        a: 1
        b : 2
        ---
        # Title
        """)

        XCTAssertEqual(markdown.metadata, [
            "a": "1",
            "b": "2"
        ])

        XCTAssertEqual(markdown.html, "<h1>Title</h1>")
    }

    func testAllowingEmptyMetadataValues() {
        let markdown = MarkdownParser().parse("""
        ---
        a: 1
        b:
        c: 2
        ---
        # Title
        """)

        XCTAssertEqual(markdown.metadata, [
            "a": "1",
            "b": "",
            "c": "2"
        ])

        XCTAssertEqual(markdown.html, "<h1>Title</h1>")
    }

    func testMergingOrphanMetadataValueIntoPreviousOne() {
        let markdown = MarkdownParser().parse("""
        ---
        a: 1
        b
        ---
        # Title
        """)

        XCTAssertEqual(markdown.metadata, ["a": "1 b"])
        XCTAssertEqual(markdown.html, "<h1>Title</h1>")
    }

    func testMissingMetadata() {
        let markdown = MarkdownParser().parse("""
        ---
        ---
        # Title
        """)

        XCTAssertEqual(markdown.metadata, [:])
        XCTAssertEqual(markdown.html, "<h1>Title</h1>")
    }
    
    func testFalseMetadata() {
        let markdown = MarkdownParser().parse("""
        ---
        Key: Verse
        This
        meta
         - data
        seems
        to
        be
        prose
        and
        has
        some
        hr ---
        markers
        at
        the
        end.

        We
        better
        fail
        out
        to
        allow
        the
        paragraph
        to
        render.

        ---
        # Title
        """)

        XCTAssertEqual(markdown.metadata, [:])
        XCTAssertEqual(markdown.html, "<hr><p>Key: Verse This meta - data seems to be prose and has some hr --- markers at the end.</p><p>We better fail out to allow the paragraph to render.</p><hr><h1>Title</h1>")
    }
    
    func testYAMLLikeMetadata() {
        let markdown = MarkdownParser().parse("""
        ---
        draft: false
        title: Privacy
        description: Privacy statement for --- Website Inc.
        language: en
        tags: []
        keywords:
          - Website Inc.
          - privacy
          - gdpr
        date: '2018-11-19T13:10:52-05:00'
        lastmod: '2017-11-24T15:15:52-05:00'
        type: webpage
        nobc: true
        ---
        # Title
        """)

        XCTAssertEqual(markdown.metadata, ["draft": "false", "lastmod": "\'2017-11-24T15:15:52-05:00\'", "description": "Privacy statement for --- Website Inc.", "nobc": "true", "tags": "", "keywords": "Website Inc.,privacy,gdpr", "date": "\'2018-11-19T13:10:52-05:00\'", "type": "webpage", "language": "en", "title": "Privacy"])
        XCTAssertEqual(markdown.html, "<h1>Title</h1>")
    }
    
    func testJustMetadata() {
        let markdown = MarkdownParser().parse("""
           ---
           a:empty file
            b:     more info
           \n
           """)
        
        XCTAssertEqual(markdown.metadata, ["b": "more info", "a": "empty file"])
        XCTAssertEqual(markdown.html, "")
    }
    
    func testStartWithRuleAndOtherNonMetaData() {
        let markdown = MarkdownParser().parse("""
        ---
             
            :: hi
        \n
        """)

        XCTAssertEqual(markdown.metadata, [:])
        XCTAssertEqual(markdown.html, "<hr><p>:: hi</p>")
    }
    
    func testStartWithRule() {
        let markdown = MarkdownParser().parse("""
        ---
        # Title
        """)

        XCTAssertEqual(markdown.metadata, [:])
        XCTAssertEqual(markdown.html, "<hr><h1>Title</h1>")
    }

    func testMetadataInWrongPlace() {
        let markdown = MarkdownParser().parse("""
        # Title
        ---
        a: 1
        b : 2
        ---
        ## Section
        """)

        XCTAssertEqual(markdown.metadata, [:])
        // This test will start to fail if the --- can be interpreted as underlining changing the paragraph to a <h2>
        // without underlining the second --- might be also an <hr> but the current parser is not looking out for ---
        XCTAssertEqual(markdown.html, "<h1>Title</h1><hr><p>a: 1 b : 2 ---</p><h2>Section</h2>")
    }

    func testPlainTextTitle() {
        let markdown = MarkdownParser().parse("""
        # Hello, world!
        """)

        XCTAssertEqual(markdown.title, "Hello, world!")
    }

    func testRemovingTrailingMarkersFromTitle() {
        let markdown = MarkdownParser().parse("""
        # Hello, world! ####
        """)

        XCTAssertEqual(markdown.title, "Hello, world!")
    }

    func testConvertingFormattedTitleTextToPlainText() {
        let markdown = MarkdownParser().parse("""
        # *Italic* **Bold** [Link](url) ![Image](url) `Code`
        """)

        XCTAssertEqual(markdown.title, "Italic Bold Link Image Code")
    }

    func testTreatingFirstHeadingAsTitle() {
        let markdown = MarkdownParser().parse("""
        # Title 1
        # Title 2
        ## Title 3
        """)

        XCTAssertEqual(markdown.title, "Title 1")
    }

    func testOverridingTitle() {
        var markdown = MarkdownParser().parse("# Title")
        markdown.title = "Title 2"
        XCTAssertEqual(markdown.title, "Title 2")
    }
}

extension MarkdownTests {
    static var allTests: Linux.TestList<MarkdownTests> {
        return [
            ("testParsingMetadata", testParsingMetadata),
            ("testAllowingEmptyMetadataValues", testAllowingEmptyMetadataValues),
            ("testMergingOrphanMetadataValueIntoPreviousOne", testMergingOrphanMetadataValueIntoPreviousOne),
            ("testMissingMetadata", testMissingMetadata),
            ("testFalseMetadata", testFalseMetadata),
            ("testYAMLLikeMetadata", testYAMLLikeMetadata),
            ("testJustMetadata", testJustMetadata),
            ("testStartWithRuleAndOtherNonMetaData", testStartWithRuleAndOtherNonMetaData),
            ("testStartWithRule", testStartWithRule),
            ("testMetadataInWrongPlace", testMetadataInWrongPlace),
            ("testPlainTextTitle", testPlainTextTitle),
            ("testRemovingTrailingMarkersFromTitle", testRemovingTrailingMarkersFromTitle),
            ("testConvertingFormattedTitleTextToPlainText", testConvertingFormattedTitleTextToPlainText),
            ("testTreatingFirstHeadingAsTitle", testTreatingFirstHeadingAsTitle),
            ("testOverridingTitle", testOverridingTitle)
        ]
    }
}
