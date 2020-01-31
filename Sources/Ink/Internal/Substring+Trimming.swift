/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal extension Substring {
    func trimmingLeadingWhitespaces() -> Self {
        drop(while: { $0.isWhitespace })
    }

    func trimmingTrailingWhitespaces() -> Self {
        var trimmed = self

        while trimmed.last?.isWhitespace == true {
            trimmed = trimmed.dropLast()
        }

        return trimmed
    }
}
