/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal extension Character {
    var escaped: String? {
        switch self {
        case ">": return "&gt;"
        case "<": return "&lt;"
        case "&": return "&amp;"
        default:
            guard let unicodeScalar = self.unicodeScalars.first?.value else { return nil }
            if unicodeScalar > 255 {
                return "&#\(unicodeScalar);"
            } else {
                return nil
            }
        }
    }
}
