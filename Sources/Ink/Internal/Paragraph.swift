/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Paragraph: Fragment {
    var modifierTarget: Modifier.Target { .paragraphs }

    private var text: FormattedText

    static func read(using reader: inout Reader) -> Paragraph {
        return Paragraph(text: .read(using: &reader))
    }

    static func read(using reader: inout Reader, ignorePrefix: String) -> Paragraph {
        return Paragraph(text: .read(using: &reader,
                                     terminator: nil,
                                     ignorePrefix: ignorePrefix))
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let body = text.html(usingURLs: urls, modifiers: modifiers)
        return "<p>\(body)</p>"
    }

    func plainText() -> String {
        text.plainText()
    }
}
