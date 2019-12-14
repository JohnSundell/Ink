/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

// first are the escapes used to make safe the HTML. Added here is the null character substitution for security.
let escapeSubstitutionsForMarkdown: [Character: String] = [
">": "&gt;",
"<": "&lt;",
"&": "&amp;",
"\"": "&quot;",    // "&#34;" is shorter than "&quot;" but commonmark tests are specifying "&quot;"
    // "&#39;" is shorter than "&apos;" and apos was not in HTML until HTML5.Commonmark tests are not specifying single quote escape
Character(Unicode.Scalar(0000)): String(Unicode.Scalar(UInt32(0xFFFD))!)
// Took some research to initialize this one. For security the null char replaced
// so it cannot be used to cause end of file/string problems somewhere else.
// I don't think this is easy to test?
// https://spec.commonmark.org/0.29/#insecure-characters
]

// now are the escapes used to make safe the HTML attribute values that are themselves in quotes. Added here is the null character substitution for security.
let escapeSubstitutionsForHTMLAttributes: [Character: String] = [
">": "&gt;",
"<": "&lt;",
"&": "&amp;",
"\"": "&quot;", // "&#34;" is shorter than "&quot;" but commonmark tests are specifying "&quot;"
"\'": "&#39;",    // "&#39;" is shorter than "&apos;" and apos was not in HTML until HTML5.
Character(Unicode.Scalar(0000)): String(Unicode.Scalar(UInt32(0xFFFD))!)
// Took some research to initialize this one. For security the null char replaced
// so it cannot be used to cause end of file/string problems somewhere else.
// I don't think this is easy to test?
// https://spec.commonmark.org/0.29/#insecure-characters
]

// This escape list seems archaic but is necessary because the backslash remains
// if used on a character that is not a deemed ASCII punctuation symbol.
// https://spec.commonmark.org/0.29/#characters-and-lines
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
    "\'": "\'", // "&#34;" maybe here for cross-site scripting security. Needs more investigation
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
    // Took some research to initialize this one. For security the null char replaced
    // so it cannot be used to cause end of file/string problems somewhere else.
    // I don't think this is easy to test?
    // https://spec.commonmark.org/0.29/#insecure-characters
    ]

func escaped(_ char: Character) -> String? { escapeSubstitutions[char] }

func escapedMarkdownHTML(_ char: Character) -> String? { escapeSubstitutionsForMarkdown[char] }
