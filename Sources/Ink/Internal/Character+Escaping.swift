/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/
// ASCII chars escapable from CommonMark spec
// \!\"\#\$\%\&\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\\\]\^\_\`\{\|\}\~
// Result desired
// !&quot;#$%&amp;'()*+,-./:;&lt;=&gt;?@[\]^_`{|}~
// An ASCII punctuation character is !, ", #, $, %, &, ', (, ), *, +, ,, -, .,/
// (U+0021–2F), :, ;, <, =, >, ?, @ (U+003A–0040), [, \, ], ^, _,`
// (U+005B–0060), {, |, }, or ~ (U+007B–007E).
let escapeSubstitutions: [Character: String] = [
    "!": "!",
    "#": "#",
    "$": "$",
    "%": "%",
    "(": "(",
    ")": ")",
    "\'": "\'",
    "*": "*",
    "+": "+",
    ",": ",",
    "-": "-",
    ".": ".",
    "/": "/",
    "\\": "\\",
    ":": ":",
    ";": ";",
    "=": "=",
    "?": "?",
    "@": "@",
    "[": "[",
    "]": "]",
    "^": "^",
    "_": "_",
    "`": "`",
    "{": "{",
    "}": "}",
    "|": "|",
    "~": "~",
    ">": "&gt;",
    "<": "&lt;",
    "&": "&amp;",
    "\"": "&quot;",
    Character(Unicode.Scalar(0000)): String(Unicode.Scalar(UInt32(0xFFFD))!),
    //Took some research to initialize this one. Security of null char replaced so it cannot be used to cause end of file/string problems somewhere else. I don't think this is easy to test?
    Character(Unicode.Scalar(UInt32(0x0021))): String(Unicode.Scalar(UInt32(0x0021))!),
    Character(Unicode.Scalar(UInt32(0x0022))): String(Unicode.Scalar(UInt32(0x0022))!),
    Character(Unicode.Scalar(UInt32(0x0023))): String(Unicode.Scalar(UInt32(0x0023))!),
    Character(Unicode.Scalar(UInt32(0x0024))): String(Unicode.Scalar(UInt32(0x0024))!),
    Character(Unicode.Scalar(UInt32(0x0025))): String(Unicode.Scalar(UInt32(0x0025))!),
    Character(Unicode.Scalar(UInt32(0x0026))): String(Unicode.Scalar(UInt32(0x0026))!),
    Character(Unicode.Scalar(UInt32(0x0027))): String(Unicode.Scalar(UInt32(0x0027))!),
    Character(Unicode.Scalar(UInt32(0x0028))): String(Unicode.Scalar(UInt32(0x0028))!),
    Character(Unicode.Scalar(UInt32(0x0029))): String(Unicode.Scalar(UInt32(0x0029))!),
    Character(Unicode.Scalar(UInt32(0x002A))): String(Unicode.Scalar(UInt32(0x002A))!),
    Character(Unicode.Scalar(UInt32(0x002B))): String(Unicode.Scalar(UInt32(0x002B))!),
    Character(Unicode.Scalar(UInt32(0x002C))): String(Unicode.Scalar(UInt32(0x002C))!),
    Character(Unicode.Scalar(UInt32(0x002D))): String(Unicode.Scalar(UInt32(0x002D))!),
    Character(Unicode.Scalar(UInt32(0x002E))): String(Unicode.Scalar(UInt32(0x002E))!),
    Character(Unicode.Scalar(UInt32(0x002F))): String(Unicode.Scalar(UInt32(0x002F))!),
    Character(Unicode.Scalar(UInt32(0x005B))): String(Unicode.Scalar(UInt32(0x005B))!),
    Character(Unicode.Scalar(UInt32(0x005C))): String(Unicode.Scalar(UInt32(0x005C))!),
    Character(Unicode.Scalar(UInt32(0x005D))): String(Unicode.Scalar(UInt32(0x005D))!),
    Character(Unicode.Scalar(UInt32(0x005E))): String(Unicode.Scalar(UInt32(0x005E))!),
    Character(Unicode.Scalar(UInt32(0x005F))): String(Unicode.Scalar(UInt32(0x005F))!),
    Character(Unicode.Scalar(UInt32(0x0060))): String(Unicode.Scalar(UInt32(0x0060))!),
    Character(Unicode.Scalar(UInt32(0x007B))): String(Unicode.Scalar(UInt32(0x007B))!),
    Character(Unicode.Scalar(UInt32(0x007C))): String(Unicode.Scalar(UInt32(0x007C))!),
    Character(Unicode.Scalar(UInt32(0x007D))): String(Unicode.Scalar(UInt32(0x007D))!),
    Character(Unicode.Scalar(UInt32(0x007E))): String(Unicode.Scalar(UInt32(0x007E))!),
    ]

func escaped(_ char: Character) -> String? { escapeSubstitutions[char] }


internal extension Character {
    @available(*, deprecated, message: "use escaped(_ char: Character) -> String?")
    var escaped: String? {
        switch self {
        case ">": return "&gt;"
        case "<": return "&lt;"
        case "&": return "&amp;"
        default: return nil
        }
    }
}
