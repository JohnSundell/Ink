/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct List: Fragment {
    private static let orderedListMarkers: Set<Character> = [".", ")"]
    
    var modifierTarget: Modifier.Target { .lists }

    private var listMarker: Character
    private var isOrdered: Bool
    private var startingIndex: Int?
    private var items = [Item]()

    static func read(using reader: inout Reader) throws -> List {
        try read(using: &reader, indentationLength: 0)
    }

    private static func read(using reader: inout Reader,
                             indentationLength: Int) throws -> List {
        let isOrdered = reader.currentCharacter.isNumber
    
        let listMarker: Character
        let startingIndex: Int?
        if isOrdered {
            let startIndex = reader.currentIndex
            defer { reader.moveToIndex(startIndex) }
            
            let startingIndexString = try reader.readCharacters(matching: \.isNumber, limit: 9)
            startingIndex = Int(startingIndexString)
            
            listMarker = try reader.readCharacter(in: List.orderedListMarkers)
        } else {
            listMarker = reader.currentCharacter
            startingIndex = nil
        }
    
        var list = List(listMarker: listMarker, isOrdered: isOrdered, startingIndex: startingIndex)

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
                    try reader.readCharacters(matching: \.isNumber, limit: 9)
                    let foundMarker = try reader.readCharacter(in: List.orderedListMarkers)

                    guard foundMarker == listMarker else {
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
        let tagName = isOrdered ? "ol" : "ul"
        
        let startAttr: String
        if let startingIndex = startingIndex, startingIndex != 1 {
            startAttr = #" start="\#(startingIndex)""#
        } else {
            startAttr = ""
        }

        let body = items.reduce(into: "") { html, item in
            html.append(item.html(usingURLs: urls, modifiers: modifiers))
        }

        return "<\(tagName)\(startAttr)>\(body)</\(tagName)>"
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
