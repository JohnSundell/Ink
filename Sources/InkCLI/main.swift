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
    exit(ExitCode.normal.rawValue)
}

let markdown: String

switch arguments.count {
case 1:
    // no arguments, parse stdin
    markdown = AnyIterator { readLine() }.joined(separator: "\n")
case let count where arguments[1] == "-m" || arguments[1] == "--markdown":
    // first argument -m or --markdown, parse Markdown string
    guard count == 3 else {
        printError("-m, --markdown flag takes a single following argument")
        printError(usageMessage)
        exit(ExitCode.badMarkdownFlagUsage.rawValue)
    }
    markdown = arguments[2]
case 2:
    // single argument, parse contents of file
    let fileUrl: URL

    switch arguments[1] {
    case let argument where argument.hasPrefix("/"):
        fileUrl = URL(fileURLWithPath: argument, isDirectory: false)
    case let argument where argument.hasPrefix("~"):
        let absoluteString = NSString(string: argument).expandingTildeInPath
        fileUrl = URL(fileURLWithPath: absoluteString, isDirectory: false)
    default:
        let dir = FileManager.default.currentDirectoryPath
        let dirUrl = URL(fileURLWithPath: dir, isDirectory: true)
        fileUrl = dirUrl.appendingPathComponent(arguments[1])
    }

    do {
        // this is 5x faster than 'markdown = try String(contentsOf: fileUrl, encoding: .utf8)'
        let data = try Data(contentsOf: fileUrl)
        markdown = String(decoding: data, as: UTF8.self)
    } catch {
        printError(error.localizedDescription)
        printError(usageMessage)
        exit(ExitCode.problemReadingFile.rawValue)
    }
default:
    // incorrect number of arguments
    printError("Too many arguments")
    printError(usageMessage)
    exit(ExitCode.tooManyArguments.rawValue)
}

let parser = MarkdownParser()
print(parser.html(from: markdown))
