/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

struct RawHTML: Fragment {
    var modifierTarget: Modifier.Target { .none }
    
    var string: Substring

    static func read(using reader: inout Reader) throws -> RawHTML {
        return RawHTML(string:"")
    }
    
    func html(usingURLs urls: NamedURLCollection, modifiers: ModifierCollection) -> String {
        return String(string)
    }
    
    func plainText() -> String {
        return ""
    }
}

