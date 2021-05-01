/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Link: Fragment {
    var modifierTarget: Modifier.Target { .links }

    var target: Target
    var text: FormattedText
    var title: Substring?

    static func read(using reader: inout Reader) throws -> Link {
        try reader.read("[")
        let text = FormattedText.read(using: &reader, terminators: ["]"])
        try reader.read("]")

        guard !reader.didReachEnd else { throw Reader.Error() }

        if reader.currentCharacter == "(" {
            reader.advanceIndex()
            let url = try? reader.readCharacters(matching: \.isLegalInURL)

            guard !reader.didReachEnd else { throw Reader.Error() }
            var titleText: Substring? = nil
            if reader.currentCharacter.isSameLineWhitespace {
                try reader.readWhitespaces()
                try reader.read("\"")
                titleText = try reader.read(until: "\"")
            }
            try reader.read(")")
            return Link(target: .url(url ?? ""), text: text, title: titleText)
        } else {
            try reader.read("[")
            let reference = try reader.read(until: "]")
            return Link(target: .reference(reference), text: text, title: nil)
        }
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let url = target.url(from: urls)
        let refTitle = target.title(from: urls)
        let linkText = text.html(usingURLs: urls, modifiers: modifiers)
        let finalTitle = refTitle ?? title
        var titleAttribute: String = ""
        if let finalTitle = finalTitle {
            titleAttribute = " title=\"\(finalTitle)\""
        }
        return "<a href=\"\(url)\"\(titleAttribute)>\(linkText)</a>"
    }

    func plainText() -> String {
        text.plainText()
    }
}

extension Link {
    enum Target {
        case url(URL)
        case reference(Substring)
    }
}

extension Link.Target {
    func url(from urls: NamedURLCollection) -> URL {
        switch self {
        case .url(let url):
            return url
        case .reference(let name):
            return urls.url(named: name)?.url ?? name
        }
    }

    func title(from urls: NamedURLCollection) -> Substring? {
        switch self {
        case .url:
            return nil
        case .reference(let name):
            return urls.url(named: name)?.title
        }
    }
}
