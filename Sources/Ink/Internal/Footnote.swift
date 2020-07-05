/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Footnote: Fragment {
    var modifierTarget: Modifier.Target { .footnotes }

    let name: String
    let contents: Substring

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        return "<li id=\"fn:\(name)\"><p>\(contents)<a href=\"#fnref:\(name)\">↩</a></p></li>"
    }

    func plainText() -> String {
        String(contents)
    }
}
