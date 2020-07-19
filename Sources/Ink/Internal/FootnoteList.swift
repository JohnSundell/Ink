/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct FootnoteList: Fragment {
    var modifierTarget: Modifier.Target { .footnoteLists }

    private let footnotes: [Footnote]
    private let footnoteDeclarations: [FootnoteDeclaration]

    init(footnotes: [Footnote],
         footnoteDeclarations: [FootnoteDeclaration]) {
        self.footnotes = footnotes
        self.footnoteDeclarations = footnoteDeclarations
    }

    func html(usingReferences references: NamedReferenceCollection,
              modifiers: ModifierCollection) -> String {
        guard footnotes.count > 0 else { return "" }
        let footnoteDeclarations = self.footnoteDeclarations.reduce(into: [String:FootnoteDeclaration]()) {
            $0[$1.name] = $1
        }
        let body = footnotes.reduce(into: "") { html, footnote in
            let name = footnote.lowercased()
            let footnoteDeclaration = footnoteDeclarations[name] ?? FootnoteDeclaration(name: name,
                                                                                        contents: FormattedText.text(name[...]))
            html.append(footnoteDeclaration.html(usingReferences: references,
                                                 modifiers: modifiers))
        }
        return "<ol>\(body)</ol>"
    }

    func plainText() -> String {
        footnotes.map(\.name).joined(separator: "\n")
    }
}
