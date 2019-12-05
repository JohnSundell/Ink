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
    /// The inferred title of the document, from any top-level
    /// heading found when parsing. If the Markdown text contained
    /// two top-level headings, then this property will contain
    /// the first one. Note that this property does not take modifiers
    /// into acccount.
    public var title: String? {
        get { makeTitle() }
        set { overrideTitle(with: newValue) }
    }
    /// Any metadata values found at the top of the Markdown
    /// document. See this project's README for more information.
    public var metadata: [String : String]

    private let titleHeading: Heading?
    private var titleStorage = TitleStorage()

    internal init(html: String,
                  titleHeading: Heading?,
                  metadata: [String : String]) {
        self.html = html
        self.titleHeading = titleHeading
        self.metadata = metadata
    }
}

private extension Markdown {
    final class TitleStorage {
        var title: String?
    }

    mutating func overrideTitle(with title: String?) {
        let storage = TitleStorage()
        storage.title = title
        titleStorage = storage
    }

    func makeTitle() -> String? {
        if let stored = titleStorage.title { return stored }
        titleStorage.title = titleHeading?.plainText()
        return titleStorage.title
    }
}
