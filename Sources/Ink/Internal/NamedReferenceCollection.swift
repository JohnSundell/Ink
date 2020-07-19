/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct NamedReferenceCollection {
    private var urlsByName = [String : URL]()
    private var footnotes = [Footnote]()
    private var footnoteDeclarations = [FootnoteDeclaration]()

    func url(named name: Substring) -> URL? {
        urlsByName[name.lowercased()]
    }

    func firstIndex(of footnote: Footnote) -> Int? {
        footnotes.firstIndex(of: footnote)
    }

    mutating func append(urlDeclaration: URLDeclaration) {
        urlsByName[urlDeclaration.name] = urlDeclaration.url
    }

    mutating func append(footnote: Footnote) {
        footnotes.append(footnote)
    }

    mutating func append(footnoteDeclaration: FootnoteDeclaration) {
        footnoteDeclarations.append(footnoteDeclaration)
    }

    func footnoteList(modifiers: ModifierCollection) -> FootnoteList? {
        guard footnotes.count > 0 else { return nil }
        return FootnoteList(footnotes: footnotes,
                            footnoteDeclarations: footnoteDeclarations)
    }
}
