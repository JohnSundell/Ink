/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/
// Some code borrowed and modified from IBM Kitura project under Apache license
/*
* Copyright IBM Corporation 2016, 2017
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
struct HTMLEntity: Fragment {
    var modifierTarget: Modifier.Target { .htmlentity }

    private var entityCharacters: String
    
    // Private enum used by the parser state machine
    private enum EntityParseState {
        case dec
        case hex
        case named
        case number
        case unknown
    }
    
    static func read(using reader: inout Reader) throws -> HTMLEntity {
        try reader.read("&")
        var entity = ""
        // current parse state
        var state: EntityParseState = .unknown
        
        while !reader.didReachEnd {
            let c = reader.currentCharacter
            switch state {
            case .unknown:
                if c == "#" {
                    state = .number
                } else if c.isLetter { // alphanumeric but all the constants seem to start with a letter.
                    state = .named
                    entity.append(c)
                } else {
                    throw Reader.Error()
                }
            case .named:
                if c.isLetter || c.isNumber { // this allows lots of extra unicode for now but will fail on lookup
                    entity.append(c)
                } else if c == ";" {
                    reader.advanceIndex()
                    entity.append(c)
                    // Step 1: check all other named characters first
                    // Assume special case is rare, always check regular case first to minimize
                    // search time cost amortization
                    if let entitycode = namedCharactersDecodeMap[entity] {
                        if let escaped = entitycode.escaped {
                            return HTMLEntity(entityCharacters: String(escaped))
                        } else {
                            return HTMLEntity(entityCharacters: String(entitycode))
                        }
                    }

                    // Step 2: check special named characters if entity didn't match any regular
                    // named character references
                    if let s = specialNamedCharactersDecodeMap[entity] {
                        return HTMLEntity(entityCharacters: s)
                    }
                    throw Reader.Error()
                } else {
                    throw Reader.Error()
                }
            case .number:
                if c == "x" || c == "X" {
                    state = .hex
                } else if c.isNumber {
                    state = .dec
                    if let asciiVal = c.asciiValue, 0x30...0x39 ~= asciiVal {
                        entity.append(c)
                    } else {
                        throw Reader.Error()
                    }
                } else {
                    throw Reader.Error()
                }
            case .dec:
                if let asciiVal = c.asciiValue, 0x30...0x39 ~= asciiVal {
                    entity.append(c)
                } else if c == ";" {
                    reader.advanceIndex()
                    if var code = UInt32(entity, radix: 10) {
                        if 0xD800...0xDFFF ~= code || 0x10FFFF < code {
                            throw Reader.Error()
                        }
                        if code == 0 {
                            code = replacementCharacterAsUInt32
                        }
                        if let ucs = Unicode.Scalar(code) {
                            let char = Character(ucs)
                            if let escaped = char.escaped {
                                return HTMLEntity(entityCharacters: String(escaped))
                            } else {
                                return HTMLEntity(entityCharacters: String(char))
                            }
                        }
                    }
                    throw Reader.Error() // need to dream up a code that has no character for coverage
                } else {
                    throw Reader.Error()
                }
            case .hex:
                if let asciiVal = c.asciiValue, 0x30...0x39 ~= asciiVal || 0x41...0x46 ~= asciiVal || 0x61...0x66 ~= asciiVal {
                    entity.append(c)
                } else if c == ";" {
                    reader.advanceIndex()
                    if var code = UInt32(entity, radix: 16) {
                        if 0xD800...0xDFFF ~= code || 0x10FFFF < code {
                            throw Reader.Error()
                        }
                        if code == 0 {
                            code = replacementCharacterAsUInt32
                        }
                        if let ucs = Unicode.Scalar(code) {
                            let char = Character(ucs)
                            if let escaped = char.escaped {
                                return HTMLEntity(entityCharacters: String(escaped))
                            } else {
                                return HTMLEntity(entityCharacters: String(char))
                            }
                        }
                    }
                    throw Reader.Error()  // need to dream up a code that has no character for coverage
                } else {
                    throw Reader.Error()
                }
            }
            reader.advanceIndex()
            if entity.count > 30 { throw Reader.Error()}
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
