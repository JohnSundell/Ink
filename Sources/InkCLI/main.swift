/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Ink

let arguments = CommandLine.arguments

if arguments.contains(where: { $0 == "-h" || $0 == "--help" }) {
    print(helpMessage)
    exit(0)
}

let markdown: String

switch arguments.count {
case 1:
    // No arguments, parse stdin
    markdown = AnyIterator { readLine() }.joined(separator: "\n")
case let count where arguments[1] == "-m" || arguments[1] == "--markdown":
    // First argument is -m or --markdown, parse Markdown string
    guard count == 3 else {
        printError("-m, --markdown flag takes a single following argument")
        printUsageMessage()
        exit(1)
    }
    markdown = arguments[2]
case 2:
    // Single argument, parse contents of file
    let fileURL: URL

    switch arguments[1] {
    case let argument where argument.hasPrefix("/"):
        fileURL = URL(fileURLWithPath: argument, isDirectory: false)
    case let argument where argument.hasPrefix("~"):
        let absoluteString = NSString(string: argument).expandingTildeInPath
        fileURL = URL(fileURLWithPath: absoluteString, isDirectory: false)
    default:
        let directory = FileManager.default.currentDirectoryPath
        let directoryURL = URL(fileURLWithPath: directory, isDirectory: true)
        fileURL = directoryURL.appendingPathComponent(arguments[1])
    }

    do {
        let data = try Data(contentsOf: fileURL)
        markdown = String(decoding: data, as: UTF8.self)
    } catch {
        printError(error.localizedDescription)
        printUsageMessage()
        exit(1)
    }
default:
    printError("Too many arguments")
    printUsageMessage()
    exit(1)
}

let parser = MarkdownParser()
print(parser.html(from: markdown))
