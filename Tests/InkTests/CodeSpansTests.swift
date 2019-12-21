/**
*  Ink
*  Copyright (c) Steve Hume 2019
*  MIT license, see LICENSE file for details
---
title: GitHub Flavored Markdown Spec
version: 0.29
date: '2019-04-06'
license: '[CC-BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/)'
...
*/

import XCTest
import Ink
import Foundation

final class CodeSpansTests: XCTestCase {

    // ## Code spans
    // 
    // A [backtick string](@)
    // is a string of one or more backtick characters (`` ` ``) that is neither
    // preceded nor followed by a backtick.
    // 
    // A [code span](@) begins with a backtick string and ends with
    // a backtick string of equal length.  The contents of the code span are
    // the characters between the two backtick strings, normalized in the
    // following ways:
    // 
    // - First, [line endings] are converted to [spaces].
    // - If the resulting string both begins *and* ends with a [space]
    //   character, but does not consist entirely of [space]
    //   characters, a single [space] character is removed from the
    //   front and back.  This allows you to include code that begins
    //   or ends with backtick characters, which must be separated by
    //   whitespace from the opening or closing backtick strings.
    // 
    // This is a simple code span:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6151-6155
    func testExample338() {
        let markdownTest =
        #####"""
        `foo`
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><code>foo</code></p>
        let normalizedCM = #####"""
        <p><code>foo</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Here two backticks are used, because the code contains a backtick.
    // This example also illustrates stripping of a single leading and
    // trailing space:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6162-6166
    func testExample339() {
        let markdownTest =
        #####"""
        `` foo ` bar ``
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><code>foo ` bar</code></p>
        let normalizedCM = #####"""
        <p><code>foo ` bar</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // This example shows the motivation for stripping leading and trailing
    // spaces:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6172-6176
    func testExample340() {
        let markdownTest =
        #####"""
        ` `` `
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><code>``</code></p>
        let normalizedCM = #####"""
        <p><code>``</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Note that only *one* space is stripped:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6180-6184
    func testExample341() {
        let markdownTest =
        #####"""
        `  ``  `
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><code> `` </code></p>
        let normalizedCM = #####"""
        <p><code>``</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // The stripping only happens if the space is on both
    // sides of the string:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6189-6193
    func testExample342() {
        let markdownTest =
        #####"""
        ` a`
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><code> a</code></p>
        let normalizedCM = #####"""
        <p><code>a</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Only [spaces], and not [unicode whitespace] in general, are
    // stripped in this way:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6198-6202
    func testExample343() {
        let markdownTest =
        #####"""
        ` b `
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><code> b </code></p>
        let normalizedCM = #####"""
        <p><code>b</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // No stripping occurs if the code span contains only spaces:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6206-6212
    func testExample344() {
        let markdownTest =
        #####"""
        ` `
        `  `\#####n
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        .replacingOccurrences(of: ">\n<", with: "><")
        
      //<p><code> </code>
      //<code>  </code></p>
        let normalizedCM = #####"""
        <p><code></code> <code></code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // [Line endings] are treated like spaces:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6217-6225
    func testExample345() {
        let markdownTest =
        #####"""
        ``
        foo
        bar
        baz
        ``\#####n
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        .replacingOccurrences(of: ">\n<", with: "><")
        
      //<p><code>foo bar   baz</code></p>
        let normalizedCM = #####"""
        <p><code>foo bar baz</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6227-6233
    func testExample346() {
        let markdownTest =
        #####"""
        ``
        foo
        ``\#####n
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        .replacingOccurrences(of: ">\n<", with: "><")
        
      //<p><code>foo </code></p>
        let normalizedCM = #####"""
        <p><code>foo</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Interior spaces are not collapsed:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6238-6243
    func testExample347() {
        let markdownTest =
        #####"""
        `foo   bar
        baz`\#####n
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        .replacingOccurrences(of: ">\n<", with: "><")
        
      //<p><code>foo   bar  baz</code></p>
        let normalizedCM = #####"""
        <p><code>foo bar baz</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Note that browsers will typically collapse consecutive spaces
    // when rendering `<code>` elements, so it is recommended that
    // the following CSS be used:
    // 
    //     code{white-space: pre-wrap;}
    // 
    // Note that backslash escapes do not work in code spans. All backslashes
    // are treated literally:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6255-6259
    func testExample348() {
        let markdownTest =
        #####"""
        `foo\`bar`
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><code>foo\</code>bar`</p>
        let normalizedCM = #####"""
        <p><code>foo\</code>bar`</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Backslash escapes are never needed, because one can always choose a
    // string of *n* backtick characters as delimiters, where the code does
    // not contain any strings of exactly *n* backtick characters.
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6266-6270
    func testExample349() {
        let markdownTest =
        #####"""
        ``foo`bar``
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><code>foo`bar</code></p>
        let normalizedCM = #####"""
        <p><code>foo`bar</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6272-6276
    func testExample350() {
        let markdownTest =
        #####"""
        ` foo `` bar `
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><code>foo `` bar</code></p>
        let normalizedCM = #####"""
        <p><code>foo `` bar</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Code span backticks have higher precedence than any other inline
    // constructs except HTML tags and autolinks.  Thus, for example, this is
    // not parsed as emphasized text, since the second `*` is part of a code
    // span:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6284-6288
    func testExample351() {
        let markdownTest =
        #####"""
        *foo`*`
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p>*foo<code>*</code></p>
        let normalizedCM = #####"""
        <p>*foo<code>*</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // And this is not parsed as a link:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6293-6297
    func testExample352() {
        let markdownTest =
        #####"""
        [not a `link](/foo`)
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p>[not a <code>link](/foo</code>)</p>
        let normalizedCM = #####"""
        <p>[not a <code>link](/foo</code>)</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // Code spans, HTML tags, and autolinks have the same precedence.
    // Thus, this is code:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6303-6307
    func testExample353() {
        let markdownTest =
        #####"""
        `<a href="`">`
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><code>&lt;a href=&quot;</code>&quot;&gt;`</p>
        let normalizedCM = #####"""
        <p><code>&lt;a href=&quot;</code>&quot;&gt;`</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // But this is an HTML tag:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6312-6316
    func testExample354() {
        let markdownTest =
        #####"""
        <a href="`">`
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><a href="`">`</p>
        let normalizedCM = #####"""
        <p><a href="`">`</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // And this is code:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6321-6325
    func testExample355() {
        let markdownTest =
        #####"""
        `<http://foo.bar.`baz>`
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><code>&lt;http://foo.bar.</code>baz&gt;`</p>
        let normalizedCM = #####"""
        <p><code>&lt;http://foo.bar.</code>baz&gt;`</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // But this is an autolink:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6330-6334
    func testExample356() {
        let markdownTest =
        #####"""
        <http://foo.bar.`baz>`
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p><a href="http://foo.bar.%60baz">http://foo.bar.`baz</a>`</p>
        let normalizedCM = #####"""
        <p><a href="http://foo.bar.%60baz">http://foo.bar.`baz</a>`</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // When a backtick string is not closed by a matching backtick string,
    // we just have literal backticks:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6340-6344
    func testExample357() {
        let markdownTest =
        #####"""
        ```foo``
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p>```foo``</p>
        let normalizedCM = #####"""
        <p>```foo``</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6347-6351
    func testExample358() {
        let markdownTest =
        #####"""
        `foo
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p>`foo</p>
        let normalizedCM = #####"""
        <p>`foo</p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

    // The following case also illustrates the need for opening and
    // closing backtick strings to be equal in length:
    // 
    //     
    // https://github.com/github/cmark-gfm/blob/master/test/spec.txt
    // spec.txt lines 6356-6360
    func testExample359() {
        let markdownTest =
        #####"""
        `foo``bar``
        """#####
    
        let html = MarkdownParser().html(from: markdownTest)
        
        
      //<p>`foo<code>bar</code></p>
        let normalizedCM = #####"""
        <p>`foo<code>bar</code></p>
        """#####
    
        XCTAssertEqual(html,normalizedCM)
    }

}

extension CodeSpansTests {
    static var allTests: Linux.TestList<CodeSpansTests> {
        return [
        ("testExample338", testExample338),
        ("testExample339", testExample339),
        ("testExample340", testExample340),
        ("testExample341", testExample341),
        ("testExample342", testExample342),
        ("testExample343", testExample343),
        ("testExample344", testExample344),
        ("testExample345", testExample345),
        ("testExample346", testExample346),
        ("testExample347", testExample347),
        ("testExample348", testExample348),
        ("testExample349", testExample349),
        ("testExample350", testExample350),
        ("testExample351", testExample351),
        ("testExample352", testExample352),
        ("testExample353", testExample353),
        ("testExample354", testExample354),
        ("testExample355", testExample355),
        ("testExample356", testExample356),
        ("testExample357", testExample357),
        ("testExample358", testExample358),
        ("testExample359", testExample359)
        ]
    }
}