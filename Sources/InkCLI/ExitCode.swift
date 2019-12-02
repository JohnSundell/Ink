/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

enum ExitCode: Int32 {
    case normal = 0
    case badMarkdownFlagUsage = 3
    case problemReadingFile
    case tooManyArguments
}
