/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Link: ReadableFragment {
    var modifierTarget: Modifier.Target { .links }

    var target: Target
    var text: FormattedText

    static func read(using reader: inout Reader) throws -> Link {
        try reader.read("[")

        let footnote: Substring?
        if reader.currentCharacter == "^" {
            reader.advanceIndex()
            // Not sure it's better to
            // 1. read the body of the footnote twice (here and for FormattedText)
            // or
            // 2. add a way to pull that text out of FormattedText
            let index = reader.currentIndex
            footnote = try reader.read(until: "]")
            reader.moveToIndex(index)
        } else {
            footnote = nil
        }

        let text = FormattedText.read(using: &reader, terminators: ["]"])

        try reader.read("]")

        guard !reader.didReachEnd else { throw Reader.Error() }

        if let footnote = footnote {
            return Link(target: .footnote(footnote), text: text)
        } else if reader.currentCharacter == "(" {
            reader.advanceIndex()
            let url = try reader.read(until: ")")
            return Link(target: .url(url), text: text)
        } else {
            try reader.read("[")
            let reference = try reader.read(until: "]")
            return Link(target: .reference(reference), text: text)
        }
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let url = target.url(from: urls)
        switch target {
        case .footnote(let name):
            return "<sup id=\"fnref:\(name)\"><a href=\"#fn:\(name)\">\(name)</a></sup>"
        default:
            let title = text.html(usingURLs: urls, modifiers: modifiers)
            return "<a href=\"\(url)\">\(title)</a>"
        }
    }

    func plainText() -> String {
        text.plainText()
    }
}

extension Link {
    enum Target {
        case url(URL)
        case reference(Substring)
        case footnote(Substring)
    }
}

extension Link.Target {
    func url(from urls: NamedURLCollection) -> URL {
        switch self {
        case .url(let url):
            return url
        case .reference(let name):
            return urls.url(named: name) ?? name
        case .footnote(let name):
            return urls.url(named: name) ?? name
        }
    }
}
