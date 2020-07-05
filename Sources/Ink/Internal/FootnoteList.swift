/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct FootnoteList: Fragment {
    var modifierTarget: Modifier.Target { .footnoteLists }

    private var footnotes = [Footnote]()

    init(footnotes: [Footnote]) {
        self.footnotes = footnotes
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let body = footnotes.reduce(into: "") { html, footnote in
            html.append(footnote.html(usingURLs: urls, modifiers: modifiers))
        }
        return "<ol>\(body)</ol>"
    }

    func plainText() -> String {
        footnotes.map(\.contents).joined(separator: "\n")
    }
}
