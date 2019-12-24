/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/
// Almost more important than specification compliance is the security of the ultimate website produced. See:
// https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html

// first are the escapes used to make safe the HTML. Added here is the null character substitution for security.
// this should be used for general HTML text and inside double-quote attributes.
let escapeSubstitutionsForMarkdown: [Character: String] = [
">": "&gt;",
"<": "&lt;",
"&": "&amp;",
"\"": "&quot;",
Character(Unicode.Scalar(0000)): String(Unicode.Scalar(UInt32(0xFFFD))!)
// Took some research to initialize this one. For security the null char replaced
// so it cannot be used to cause end of file/string problems somewhere else.
// I don't think this is easy to test?
// https://spec.commonmark.org/0.29/#insecure-characters
]

// now are the escapes used to make safe the HTML attribute values
// that are themselves in single quotes or double quotes.
// Added here is the null character substitution for security.
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

// For future reference to anyone thinking of escaping text allowed in unquoted attributes. (Very scary and messy)
// Except for alphanumeric characters, escape all characters with ASCII values less than 256 with the &#xHH;
// format (or a named entity if available) to prevent switching out of the attribute.
// The reason this rule is so broad is that developers frequently leave attributes unquoted.
// Properly quoted attributes can only be escaped with the corresponding quote.
// Unquoted attributes can be broken out of with many characters, including [space] % * + , - / ; < = > ^ and |.

// This escape list seems archaic but is necessary because the backslash remains
// if used on a character that is not a deemed ASCII punctuation symbol.
// https://spec.commonmark.org/0.29/#characters-and-lines
// An ASCII punctuation character is !, ", #, $, %, &, ', (, ), *, +, ,, -, .,/
// (U+0021–2F), :, ;, <, =, >, ?, @ (U+003A–0040), [, \, ], ^, _,`
// (U+005B–0060), {, |, }, or ~ (U+007B–007E).

// A future performance opportunity is to discover if loading a [Bool]
// just for low order ASCII is faster than a dictionary.
let escapeSubstitutionsTruthDict: [Character: Bool] =
    #####"""
    !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~
    """#####.reduce(into: [:]) {result,char in
    result[char] = true
}
/// Use to meet the CommonMark spec.
/// to backslash escape the ASCII punctuation characters
///
/// An ASCII punctuation character is
///
///  !, ", #, $, %, &, ', (, ), *, +, ,, -, .,/ (U+0021–2F),
///
///  :, ;, <, =, >, ?, @ (U+003A–0040),
///
///  [, \, ], ^, _,`(U+005B–0060),
///
///  {, |, }, or ~ (U+007B–007E).
///
/// - Parameter char: A single Character
func escapedASCIIPunctuation(_ char: Character) -> Bool {escapeSubstitutionsTruthDict[char] ?? false}

/// A minimal HTML escape for html text and attributes inside double quotes
/// If nil is returned the character is not needing html escaping.
///
/// ">": "\&gt;",  "<": "\&lt;", "&": "\&amp;", "\"": "\&quot;",
/// And for security the Null character is substituted.
/// Character(Unicode.Scalar(0000)): String(Unicode.Scalar(UInt32(0xFFFD))!)
/// - Parameter char: A single Character
func escapedMarkdownHTML(_ char: Character) -> String? { escapeSubstitutionsForMarkdown[char] }

/// A minimal HTML escape for html text and attributes inside double quotes
///
/// Use on HTML output phase to escape Substrings to output Strings.
///
/// /// ">": "\&gt;",  "<": "\&lt;", "&": "\&amp;", "\"": "\&quot;",
///
/// And for security the Null character is substituted.
///
/// Character(Unicode.Scalar(0000)): String(Unicode.Scalar(UInt32(0xFFFD))!)
/// - Parameter substring: A substring of the original input usually
func htmlEscapeASubstring(_ substring: Substring) -> String {
     substring.reduce(into: ""){result,char in
        result.append(contentsOf: escapeSubstitutionsForMarkdown[char] ?? String(char))
    }
}

/// A minimal HTML escape for html text and attributes inside double quotes
///
/// Use on HTML output phase to escape Strings to output Strings.
///
/// /// ">": "\&gt;",  "<": "\&lt;", "&": "\&amp;", "\"": "\&quot;",
///
/// And for security the Null character is substituted.
///
/// Character(Unicode.Scalar(0000)): String(Unicode.Scalar(UInt32(0xFFFD))!)
/// - Parameter str: The input is already a String
func htmlEscapeAString(_ str: String) -> String {
     return htmlEscapeASubstring(Substring(str))
    }

// prebuild an array to use for escaping URI
let uriEncodedStrings: [String] = Array(repeating: "   ", count: 256).enumerated().map{ (index, element) in
    if let uc = Unicode.Scalar(index) {
        let char = Character(uc)
        /* From the commonmark code comments
         * The following characters will not be escaped:
         *
         *        -_.+!*'(),%#@?=;:/,+&$ alphanum
         *
         * Note that this character set is the addition of:
         *
         *    - The characters which are safe to be in an URL
         *    - The characters which are *not* safe to be in
         *    an URL because they are RESERVED characters.
         *
         * We asume (lazily) that any RESERVED char that
         * appears inside an URL is actually meant to
         * have its native function (i.e. as an URL
         * component/separator) and hence needs no escaping.
         *
         * There are two exceptions: the chacters & (amp)
         * and ' (single quote) do not appear in the table.
         * They are meant to appear in the URL as components,
         * yet they require special HTML-entity escaping
         * to generate valid HTML markup.
         *
         * All other characters will be escaped to %XX.
         *
         */
        if char.isLetter || char.isWholeNumber || "~-_.+!*'(),%#@?=;:/,+&$".contains(char) {  // even though ~-_. are the official chars
            return String(char)
        } else if char == "&" {
            return "&amp;" // always required in html
        } else if char == "\'" {
            return "&#x27;"  // CommonMark does this safety against single quoted attributes
        }
    }
    let hexChars:[String] = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
    return "%" + hexChars[index >> 4] + hexChars[index & 0x0F]
}
/// The URI escape specified by CommonMark
///
///  The following characters will not be escaped:
///
///     - -_.+!*'(),%#@?=;:/,+&$ alphanum
///
///  Note that this character set is the addition of:
///
///     - The characters which are safe to be in an URL
///     - The characters which are *not* safe to be in
///     an URL because they are RESERVED characters.
///
///  We asume (lazily) that any RESERVED char that
///  appears inside an URL is actually meant to
///  have its native function (i.e. as an URL
///  component/separator) and hence needs no escaping.
///
///  There are two exceptions: the chacters & (amp)
///  and ' (single quote) do not appear in the table.
///  They are meant to appear in the URL as components,
///  yet they require special HTML-entity escaping
///  to generate valid HTML markup.
/// - Parameter substring: A URI substring to escape for output
func uriEncoded(uriSubstring substring: Substring) -> String {
    substring.reduce(into: ""){result, char in
        if char.isASCII {
            result.append(contentsOf: uriEncodedStrings[Int(char.unicodeScalars.map { $0.value }.reduce(0, +))])
        } else {
            result.append(char)
        }
    }
}
