/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct List: Fragment {
    var modifierTarget: Modifier.Target { .lists }

    private var listMarker: Character
    private var kind: Kind
    private var items = [Item]()

    static func read(using reader: inout Reader) throws -> List {
        // Calculate initial indentation
        var indentationLength = 0
        while reader.previousCharacter?.isSameLineWhitespace == true {
            indentationLength += 1
            reader.rewindIndex()
        }
        reader.advanceIndex(by: indentationLength)
        
        return try read(using: &reader, indentationLength: indentationLength)
    }

    private static func read(using reader: inout Reader,
                             indentationLength: Int) throws -> List {
        let startIndex = reader.currentIndex
        let isOrdered = reader.currentCharacter.isNumber

        var list: List

        if isOrdered {
            let firstNumberString = try reader.readCharacters(matching: \.isNumber, max: 9)
            let firstNumber = Int(firstNumberString) ?? 1
            
            let listMarker = try reader.readCharacter(in: List.orderedListMarkers)
            list = List(listMarker: listMarker, kind: .ordered(firstNumber: firstNumber))
        } else {
            let listMarker = reader.currentCharacter
            list = List(listMarker: listMarker, kind: .unordered)
        }

        reader.moveToIndex(startIndex)

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
            case \.isNumber:
                guard case .ordered = list.kind else {
                    try addTextToLastItem()
                    continue
                }

                let startIndex = reader.currentIndex

                do {
                    try reader.readCharacters(matching: \.isNumber, max: 9)
                    let foundMarker = try reader.readCharacter(in: List.orderedListMarkers)

                    guard foundMarker == list.listMarker else {
                        reader.moveToIndex(startIndex)
                        return list
                    }

                    try reader.readWhitespaces()

                    list.items.append(Item(text: .readLine(using: &reader)))
                } catch {
                    reader.moveToIndex(startIndex)
                    try addTextToLastItem()
                }
            case "-", "*", "+":
                guard let nextCharacter = reader.nextCharacter,
                      nextCharacter.isSameLineWhitespace else {
                    try addTextToLastItem()
                    continue
                }

                guard reader.currentCharacter == list.listMarker else {
                    return list
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
        let tagName: String
        let startAttribute: String

        switch kind {
        case .unordered:
            tagName = "ul"
            startAttribute = ""
        case let .ordered(startingIndex):
            tagName = "ol"

            if startingIndex != 1 {
                startAttribute = #" start="\#(startingIndex)""#
            } else {
                startAttribute = ""
            }
        }

        let body = items.reduce(into: "") { html, item in
            html.append(item.html(usingURLs: urls, modifiers: modifiers))
        }

        return "<\(tagName)\(startAttribute)>\(body)</\(tagName)>"
    }

    func plainText() -> String {
        var isFirst = true

        return items.reduce(into: "") { string, item in
            if isFirst {
                isFirst = false
            } else {
                string.append(", ")
            }

            string.append(item.text.plainText())
        }
    }
}

private extension List {
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

    enum Kind {
        case unordered
        case ordered(firstNumber: Int)
    }

    static let orderedListMarkers: Set<Character> = [".", ")"]
}
