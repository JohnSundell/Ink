/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct FootnoteDeclaration: ReadableFragment {
    var modifierTarget: Modifier.Target { Modifier.Target.footnoteListItems }

    let name: String
    let contents: FormattedText

    static func read(using reader: inout Reader,
                     references: inout NamedReferenceCollection) throws -> Self {
        try reader.read("[")

        if reader.currentCharacter != "^" {
            throw Reader.Error()
        }

        reader.advanceIndex()

        let name = try reader.read(until: "]").lowercased()
        try reader.read(":")
        try reader.readWhitespaces()
        let contents = FormattedText.readLine(using: &reader,
                                              references: &references)

        return FootnoteDeclaration(name: name,
                                   contents: contents)
    }

    func html(usingReferences references: NamedReferenceCollection,
              modifiers: ModifierCollection) -> String {
        guard let index = references.firstIndex(of: Footnote(name: name[...])) else { return "" }
        return "<li id=\"fn:\(index + 1)\"><p>\(contents.html(usingReferences: references, modifiers: modifiers))<a href=\"#fnref:\(index + 1)\">↩</a></p></li>"
    }

    func plainText() -> String {
        contents.plainText()
    }
}
