/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation


internal struct Link: Fragment {
    var modifierTarget: Modifier.Target { .links }

    var target: Target
    var text: FormattedText
    var attributes: [Attribute] = []

    init(target: Target, text: FormattedText) {
        self.target = target
        self.text = text
    }

    init(url: Substring, text: FormattedText) {
        let parts = url.unicodeScalars.split(whereSeparator: { CharacterSet.whitespaces.contains($0) })
        if parts.count > 1 {
            self.target = .url(String(parts.first!)[...])
            self.attributes = parts
                .dropFirst()
                .map(String.init)
                .compactMap(Attribute.init)
        } else {
            self.target = .url(url)
        }
        self.text = text
    }

    static func read(using reader: inout Reader) throws -> Link {
        try reader.read("[")
        let text = FormattedText.read(using: &reader, terminator: "]")
        try reader.read("]")

        guard !reader.didReachEnd else { throw Reader.Error() }

        if reader.currentCharacter == "(" {
            reader.advanceIndex()
            let url = try reader.read(until: ")")
            return Link(url: url, text: text)
        } else {
            try reader.read("[")
            let reference = try reader.read(until: "]")
            return Link(target: .reference(reference), text: text)
        }
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let url = target.url(from: urls)
        let title = text.html(usingURLs: urls, modifiers: modifiers)
        var attr = attributes
            .map({ $0.html(usingURLs: urls, modifiers: modifiers)})
            .joined(separator: " ")

        if !attr.isEmpty {
            attr = " " + attr
        }

        return "<a href=\"\(url)\"\(attr)>\(title)</a>"
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
            return urls.url(named: name) ?? name
        }
    }
}
