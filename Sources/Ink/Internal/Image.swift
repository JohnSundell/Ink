/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Image: ReadableFragment {
    var modifierTarget: Modifier.Target { .images }

    private var link: Link

    static func read(using reader: inout Reader,
                     references: inout NamedReferenceCollection) throws -> Image {
        try reader.read("!")
        return try Image(link: .read(using: &reader,
                                     references: &references))
    }

    func html(usingReferences references: NamedReferenceCollection,
              modifiers: ModifierCollection) -> String {
        let url = link.target.url(from: references)
        var alt = link.text.html(usingReferences: references, modifiers: modifiers)

        if !alt.isEmpty {
            alt = " alt=\"\(alt)\""
        }

        return "<img src=\"\(url)\"\(alt)/>"
    }

    func plainText() -> String {
        link.plainText()
    }
}
