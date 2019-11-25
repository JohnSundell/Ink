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
    and HTML will be returned as output.
    """)
    exit(0)
}

let markdown = CommandLine.arguments[1]
let parser = MarkdownParser()
print(parser.html(from: markdown))
