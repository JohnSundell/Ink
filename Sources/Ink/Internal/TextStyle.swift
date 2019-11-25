/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal enum TextStyle {
    case italic
    case bold
    case strikethrough
}

extension TextStyle {
    var htmlTagName: String {
        switch self {
        case .italic: return "em"
        case .bold: return "strong"
        case .strikethrough: return "s"
        }
    }
}
