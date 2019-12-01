/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Ink

if CommandLine.arguments.contains(where: { $0 == "-h" || $0 == "--help" }) {
    print(helpMessage, on: .standardOut)
    exit(0)
}

if CommandLine.arguments.contains(where: { $0 == "--version" }) {
    print(versionMessage, on: .standardOut)
    exit(0)
}

let markdown: String

if CommandLine.arguments.count == 1 {
    // no arguments, parse stdin
    markdown = AnyIterator { readLine() }.joined(separator: "\n")
} else if CommandLine.arguments[1] == "-m" || CommandLine.arguments[1] == "--markdown" {
    // first argument -m or --markdown, parse Markdown string
    guard CommandLine.arguments.count == 3 else {
        print("-m, --markdown flag takes a single following argument", on: .standardError)
        print(usageMessage, on: .standardError)
        exit(1)
    }
    markdown = CommandLine.arguments[2]
} else if CommandLine.arguments.count == 2 {
    // single argument, parse contents of file
    let fileUrl: URL
    if CommandLine.arguments[1].hasPrefix("/") {
        fileUrl = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: false)
    } else {
        let dir = FileManager.default.currentDirectoryPath
        let dirUrl = URL(fileURLWithPath: dir, isDirectory: true)
        fileUrl = dirUrl.appendingPathComponent(CommandLine.arguments[1])
    }

    do {
        // this is 5x more efficient than 'let data = try String(contentsOf: fileUrl)'
        let data = try Data(contentsOf: fileUrl)
        guard let string = String(data: data, encoding: .utf8) else {
            throw StringReadingError()
        }

        markdown = string
    } catch {
        print(error.localizedDescription, on: .standardError)
        print(usageMessage, on: .standardError)
        exit(2)
    }
} else {
    // incorrect number of arguments
    print("Too many arguments", on: .standardError)
    print(usageMessage, on: .standardError)
    exit(3)
}

let parser = MarkdownParser()
print(parser.html(from: markdown), on: .standardOut)
exit(0)
