/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

internal var versionMessage: String = "Ink (v0.1.2): Markdown -> HTML converter"

internal var usageMessage: String = """
Usage:  ink [file | -m markdown]
Options:
  --markdown, -m    Parse a markdown string directly
  --help, -h        Print usage information
  --version         Print version
"""

internal var helpMessage: String = """
\(versionMessage)
-------------------------------
\(usageMessage)

Ink takes Markdown formatted text as input,
and returns HTML as output. If called without
arguments, it will read from STDIN. If called
with a single argument, the file at the
specified path will be used as input. If
called with the -m option, the following
argument will be parsed as a Markdown string.
"""

internal enum Output { case standardOut, standardError }

internal func print(_ message: String, on output: Output) {
    switch output {
    case .standardOut:
        print(message)
    case .standardError:
        fputs("\(message)\n", stderr)
    }
}

struct StringReadingError: Error {}
