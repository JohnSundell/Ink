/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Paragraph: ReadableFragment {
    var modifierTarget: Modifier.Target { .paragraphs }

    private var text: FormattedText

    static func read(using reader: inout Reader,
                     references: inout NamedReferenceCollection) -> Paragraph {
        return Paragraph(text: .read(using: &reader,
                                     references: &references))
    }

    func html(usingReferences references: NamedReferenceCollection,
              modifiers: ModifierCollection) -> String {
        let body = text.html(usingReferences: references, modifiers: modifiers)
        return "<p>\(body)</p>"
    }

    func plainText() -> String {
        text.plainText()
    }
}
