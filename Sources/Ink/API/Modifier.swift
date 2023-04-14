/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

///
/// Modifiers can be attached to a `MarkdownParser` and are used
/// to customize Ink's parsing process. Each modifier is associated
/// with a given `Target`, which determines which type of Markdown
/// fragments that it is capable of modifying.
///
/// You can use a `Modifier` to adjust the HTML that was generated
/// for a given fragment, or to inject completely custom HTML based
/// on the fragment's raw Markdown representation.
public struct Modifier {
    /// The type of input that each modifier is given, which both
    /// contains the HTML that was generated for a fragment, and
    /// its raw Markdown representation. Note that for metadata
    /// targets, the two input arguments will be equivalent.
    public typealias Input = (html: String, markdown: Substring)
    /// The type of closure that Modifiers are based on. Each
    /// modifier is given a set of input, and is expected to return
    /// an HTML string after performing its modifications.
    public typealias Closure = (Input) -> String

    /// The modifier's target, that defines what kind of fragment
    /// that it's used to modify. See `Target` for more info.
    public var target: Target
    /// The closure that makes up the modifier's body.
    public var closure: Closure

    /// Initialize an instance with the kind of target that the modifier
    /// should be used on, and a closure that makes up its body.
    public init(target: Target, closure: @escaping Closure) {
        self.target = target
        self.closure = closure
    }
}

public extension Modifier {
    enum Target {
        case metadataKeys
        case metadataValues
        case blockquotes
        case codeBlocks
        case headings
        case horizontalLines
        case html
        case images
        case inlineCode
        case links
        case lists
        case paragraphs
        case tables
        case math
    }
}
