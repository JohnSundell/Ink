/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

///
/// A parsed Markdown value, which contains its rendered
/// HTML representation, as well as any metadata found at
/// the top of the Markdown document.
///
/// You create instances of this type by parsing Markdown
/// strings using `MarkdownParser`.
public struct Markdown {
    /// The HTML representation of the Markdown, ready to
    /// be rendered in a web browser.
    public var html: String
    /// Any metadata values found at the top of the Markdown
    /// document. See this project's README for more information.
    public var metadata: [String : String]
}
