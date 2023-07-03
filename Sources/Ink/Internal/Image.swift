/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/


internal struct Image: Fragment {
    var modifierTarget: Modifier.Target { .images }

    private var link: Link
    private var caption: String?

    static func read(using reader: inout Reader) throws -> Image {
        try reader.read("!")
        let _link = try Link.read(using: &reader)
        let currentIndex = reader.currentIndex
        let white = String(reader.readUntilEndOfLine())
        guard white.trimmingCharacters(in: .whitespacesAndNewlines) == "" else {
            reader.moveToIndex(currentIndex)
            return Image(link: _link, caption: nil)
        }
        guard !reader.didReachEnd && reader.currentCharacter == "*" else {
            reader.moveToIndex(currentIndex)
            return Image(link: _link, caption: nil)
        }
        reader.advanceIndex()
        do {
            let  _caption = try reader.read(until: "*")
            return Image(link: _link,caption: String(_caption))
        } catch {
            reader.moveToIndex(currentIndex)
            return Image(link: _link, caption: nil)
        }
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let url = link.target.url(from: urls)
        var alt = link.text.html(usingURLs: urls, modifiers: modifiers)

        if !alt.isEmpty {
            alt = " alt=\"\(alt)\""
        }

        if let figCaption = caption {
            return "<figure><img src=\"\(url)\"\(alt)/> <figcaption>\(figCaption)</figcaption></figure>"
        }
        return "<img src=\"\(url)\"\(alt)/>"
    }

    func plainText() -> String {
        link.plainText()
    }
}
