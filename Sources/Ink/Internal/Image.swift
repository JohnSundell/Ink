/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Image: Fragment {
    var modifierTarget: Modifier.Target { .images }

    private var link: Link

    static func read(using reader: inout Reader) throws -> Image {
        try reader.read("!")
        return try Image(link: .read(using: &reader))
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let url = link.target.url(from: urls)
        var alt = link.text.html(usingURLs: urls, modifiers: modifiers)
        var attr = link.attributes
            .map({ $0.html(usingURLs: urls, modifiers: modifiers)})
            .joined(separator: " ")

        if !alt.isEmpty {
            alt = " alt=\"\(alt)\""
        }

        if !attr.isEmpty {
            attr = " " + attr
        }

        return "<img src=\"\(url)\"\(alt)\(attr)/>"
    }

    func plainText() -> String {
        link.plainText()
    }
}
