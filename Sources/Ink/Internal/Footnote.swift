/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Footnote: ReadableFragment, Equatable {
    var modifierTarget: Modifier.Target { .footnotes }

    let name: Substring

    static func read(using reader: inout Reader,
                     references: inout NamedReferenceCollection) throws -> Self {
        try reader.read("[")

        if reader.currentCharacter != "^" {
            throw Reader.Error()
        }

        reader.advanceIndex()

        let name = try reader.read(until: "]")

        return Footnote(name: name)
    }

    func html(usingReferences references: NamedReferenceCollection,
              modifiers: ModifierCollection) -> String {
        guard let index = references.firstIndex(of: self) else { return "" }
        return "<sup id=\"fnref:\(index + 1)\"><a href=\"#fn:\(index + 1)\">\(index + 1)</a></sup>"
    }

    func plainText() -> String {
        String(name)
    }

    static func == (lhs: Footnote, rhs: Footnote) -> Bool {
        lhs.lowercased() == rhs.lowercased()
    }

    func lowercased() -> String { name.lowercased() }
}
