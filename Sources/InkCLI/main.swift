/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Ink

guard CommandLine.arguments.count > 1 else {
    print("""
    Ink: Markdown -> HTML converter
    -------------------------------
    Pass a Markdown string to convert as input,
    and HTML will be returned as output. To use
    STDIN as input, call ink with "-" as a single
    argument, like this: '$ ink -'.
    """)
    exit(0)
}

var markdown = CommandLine.arguments[1]

if markdown == "-" {
    markdown = AnyIterator { readLine() }.joined(separator: "\n")
}

let parser = MarkdownParser()
print(parser.html(from: markdown))
