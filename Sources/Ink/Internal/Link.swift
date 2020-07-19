/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Link: ReadableFragment {
    var modifierTarget: Modifier.Target { .links }

    var target: Target
    var text: FormattedText

    static func read(using reader: inout Reader,
                     references: inout NamedReferenceCollection) throws -> Link {
        try reader.read("[")

        if reader.currentCharacter == "^" {
            throw Reader.Error()
        }

        let text = FormattedText.read(using: &reader,
                                      references: &references,
                                      terminators: ["]"])

        try reader.read("]")

        guard !reader.didReachEnd else { throw Reader.Error() }

        if reader.currentCharacter == "(" {
            reader.advanceIndex()
            let url = try reader.read(until: ")")
            return Link(target: .url(url),
                        text: text)
        } else {
            try reader.read("[")
            let reference = try reader.read(until: "]")
            return Link(target: .reference(reference),
                        text: text)
        }
    }

    func html(usingReferences references: NamedReferenceCollection,
              modifiers: ModifierCollection) -> String {
        let url = target.url(from: references)
        switch target {
        default:
            let title = text.html(usingReferences: references,
                                  modifiers: modifiers)
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
    }
}

extension Link.Target {
    func url(from references: NamedReferenceCollection) -> URL {
        switch self {
        case .url(let url):
            return url
        case .reference(let name):
            return references.url(named: name) ?? name
        }
    }
}
