/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/
struct HTMLEntity: Fragment {
    var modifierTarget: Modifier.Target { .htmlentity }

    private var entityCharacters: String

    static func read(using reader: inout Reader) throws -> HTMLEntity {
        try reader.read("&")
        var value = ""

        while !reader.didReachEnd {
            switch reader.currentCharacter {
            case \.isWhitespace:
                throw Reader.Error()
            case ";":
                value.append(reader.currentCharacter)
                reader.advanceIndex()
                if let result = namedCharactersDecodeMap[value] {
                    if let escaped = result.escaped {
                        return HTMLEntity(entityCharacters: String(escaped))
                    } else {
                        return HTMLEntity(entityCharacters: String(result))
                    }
                } else {
                    throw Reader.Error()
                }
            default:
                value.append(reader.currentCharacter)

                reader.advanceIndex()
            }
        }

        throw Reader.Error()
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        return "\(entityCharacters)"
    }

    func plainText() -> String {
        entityCharacters
    }
}
