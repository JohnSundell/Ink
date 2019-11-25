/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct List: Fragment {
    var modifierTarget: Modifier.Target { .lists }

    private var isOrdered: Bool
    private var items = [Item]()

    static func read(using reader: inout Reader) throws -> List {
        try read(using: &reader, indentationLength: 0)
    }

    private static func read(using reader: inout Reader,
                             indentationLength: Int) throws -> List {
        var list = List(isOrdered: reader.currentCharacter.isNumber)

        func addTextToLastItem() throws {
            try require(!list.items.isEmpty)
            let text = FormattedText.readLine(using: &reader)
            var lastItem = list.items.removeLast()
            lastItem.text.append(text, separator: " ")
            list.items.append(lastItem)
        }

        while !reader.didReachEnd {
            switch reader.currentCharacter {
            case \.isNewline:
                return list
            case \.isWhitespace:
                guard !list.items.isEmpty else {
                    try reader.readWhitespaces()
                    continue
                }

                let itemIndentationLength = try reader.readWhitespaces().count

                if itemIndentationLength < indentationLength {
                    return list
                } else if itemIndentationLength == indentationLength {
                    continue
                }

                let fallbackIndex = reader.currentIndex

                do {
                    let nestedList = try List.read(
                        using: &reader, indentationLength:
                        itemIndentationLength
                    )

                    var lastItem = list.items.removeLast()
                    lastItem.nestedList = nestedList
                    list.items.append(lastItem)
                } catch {
                    reader.moveToIndex(fallbackIndex)
                    try addTextToLastItem()
                }
            case \.isNumber where list.isOrdered:
                let startIndex = reader.currentIndex

                do {
                    try reader.readCharacters(matching: \.isNumber)
                    try reader.read(".")
                    try reader.readWhitespaces()

                    list.items.append(Item(text: .readLine(using: &reader)))
                } catch {
                    reader.moveToIndex(startIndex)
                    try addTextToLastItem()
                }
            case "-", "*":
                guard let nextCharacter = reader.nextCharacter,
                      nextCharacter.isSameLineWhitespace else {
                    try addTextToLastItem()
                    continue
                }

                reader.advanceIndex()
                try reader.readWhitespaces()
                list.items.append(Item(text: .readLine(using: &reader)))
            default:
                try addTextToLastItem()
            }
        }

        return list
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        let tagName = isOrdered ? "ol" : "ul"

        let body = items.reduce(into: "") { html, item in
            html.append(item.html(usingURLs: urls, modifiers: modifiers))
        }

        return "<\(tagName)>\(body)</\(tagName)>"
    }
}

extension List {
    struct Item: HTMLConvertible {
        var text: FormattedText
        var nestedList: List? = nil

        func html(usingURLs urls: NamedURLCollection,
                  modifiers: ModifierCollection) -> String {
            let textHTML = text.html(usingURLs: urls, modifiers: modifiers)
            let listHTML = nestedList?.html(usingURLs: urls, modifiers: modifiers)
            return "<li>\(textHTML)\(listHTML ?? "")</li>"
        }
    }
}
