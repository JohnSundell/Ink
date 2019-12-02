/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Ink

if CommandLine.arguments.contains(where: { $0 == "-h" || $0 == "--help" }) {
    print(helpMessage)
    exit(0)
}

let markdown: String
let arguments = CommandLine.arguments

switch arguments.count {
case 1:
    // no arguments, parse stdin
    markdown = AnyIterator { readLine() }.joined(separator: "\n")
case let count where arguments[1] == "-m" || arguments[1] == "--markdown":
    // first argument -m or --markdown, parse Markdown string
    guard count == 3 else {
        printError("-m, --markdown flag takes a single following argument")
        printError(usageMessage)
        exit(1)
    }
    markdown = CommandLine.arguments[2]
case 2:
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
        // this is 5x faster than 'let string = try String(contentsOf: fileUrl)'
        let data = try Data(contentsOf: fileUrl)
        markdown = String(decoding: data, as: UTF8.self)
    } catch {
        printError(error.localizedDescription)
        printError(usageMessage)
        exit(2)
    }
default:
    // incorrect number of arguments
    printError("Too many arguments")
    printError(usageMessage)
    exit(3)
}

let parser = MarkdownParser()
print(parser.html(from: markdown))
