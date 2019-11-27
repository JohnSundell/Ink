/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct Reader {
    private let string: String
    private(set) var currentIndex: String.Index

    init(string: String) {
        self.string = string
        self.currentIndex = string.startIndex
    }
}

extension Reader {
    struct Error: Swift.Error {}

    var didReachEnd: Bool { currentIndex == endIndex }
    var previousCharacter: Character? { lookBehindAtPreviousCharacter() }
    var currentCharacter: Character { string[currentIndex] }
    var nextCharacter: Character? { lookAheadAtNextCharacter() }
    var endIndex: String.Index { string.endIndex }

    func characters(in range: Range<String.Index>) -> Substring {
        return string[range]
    }

    mutating func read(_ character: Character) throws {
        guard !didReachEnd else { throw Error() }
        guard currentCharacter == character else { throw Error() }
        advanceIndex()
    }

    @discardableResult
    mutating func read(until character: Character,
                       required: Bool = true,
                       allowLineBreaks: Bool = false) throws -> Substring {
        let startIndex = currentIndex

        while !didReachEnd {
            guard currentCharacter != character else {
                let result = string[startIndex..<currentIndex]
                advanceIndex()
                return result
            }

            if !allowLineBreaks, currentCharacter.isNewline {
                break
            }

            advanceIndex()
        }

        if required { throw Error() }
        return string[startIndex..<currentIndex]
    }

    mutating func readCount(of character: Character) -> Int {
        var count = 0

        while !didReachEnd {
            guard currentCharacter == character else { break }
            count += 1
            advanceIndex()
        }

        return count
    }

    @discardableResult
    mutating func readCharacters(matching keyPath: KeyPath<Character, Bool>, limit: Int = Int.max) throws -> Substring {
        let startIndex = currentIndex
        var readCount = 0
        
        while !didReachEnd && readCount < limit {
            guard currentCharacter[keyPath: keyPath] else {
                break
            }

            advanceIndex()
            readCount += 1
        }

        guard startIndex != currentIndex else {
            throw Error()
        }

        return string[startIndex..<currentIndex]
    }
    
    @discardableResult
    mutating func readCharacter(in set: Set<Character>) throws -> Character {
        guard !didReachEnd else { throw Error() }
        guard set.contains(currentCharacter) else { throw Error() }
        defer { advanceIndex() }

        return currentCharacter
    }

    @discardableResult
    mutating func readWhitespaces() throws -> Substring {
        try readCharacters(matching: \.isSameLineWhitespace)
    }

    mutating func readUntilEndOfLine() -> Substring {
        let startIndex = currentIndex

        while !didReachEnd {
            guard !currentCharacter.isNewline else {
                let text = string[startIndex..<currentIndex]
                advanceIndex()
                return text
            }

            advanceIndex()
        }

        return string[startIndex..<currentIndex]
    }

    mutating func discardWhitespacesAndNewlines() {
        while !didReachEnd {
            guard currentCharacter.isWhitespace else { return }
            advanceIndex()
        }
    }

    mutating func advanceIndex(by offset: Int = 1) {
        currentIndex = string.index(currentIndex, offsetBy: offset)
    }

    mutating func rewindIndex() {
        currentIndex = string.index(before: currentIndex)
    }

    mutating func moveToIndex(_ index: String.Index) {
        currentIndex = index
    }
}

private extension Reader {
    func lookBehindAtPreviousCharacter() -> Character? {
        guard currentIndex != string.startIndex else { return nil }
        let previousIndex = string.index(before: currentIndex)
        return string[previousIndex]
    }

    func lookAheadAtNextCharacter() -> Character? {
        guard !didReachEnd else { return nil }
        let nextIndex = string.index(after: currentIndex)
        guard nextIndex != string.endIndex else { return nil }
        return string[nextIndex]
    }
}
