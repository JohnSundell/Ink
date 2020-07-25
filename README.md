<p align="center">
    <img src="Logo.png" width="278" max-width="90%" alt=“Ink” />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.2-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
     <img src="https://img.shields.io/badge/platforms-mac+linux-brightgreen.svg?style=flat" alt="Mac + Linux" />
    <a href="https://twitter.com/johnsundell">
        <img src="https://img.shields.io/badge/twitter-@johnsundell-blue.svg?style=flat" alt="Twitter: @johnsundell" />
    </a>
</p>

Welcome to **Ink**, a fast and flexible Markdown parser written in Swift. It can be used to convert Markdown-formatted strings into HTML, and also supports metadata parsing, as well as powerful customization options for fine-grained post-processing. It was built with a focus on Swift-based web development and other HTML-centered workflows.

Ink is used to render all articles on [swiftbysundell.com](https://swiftbysundell.com).

## Converting Markdown into HTML

To get started with Ink, all you have to do is to import it, and use its `MarkdownParser` type to convert any Markdown string into efficiently rendered HTML:

```swift
import Ink

let markdown: String = ...
let parser = MarkdownParser()
let html = parser.html(from: markdown)
```

That’s it! The resulting HTML can then be displayed as-is, or embedded into some other context — and if that’s all you need Ink for, then no more code is required.

## Automatic metadata parsing

Ink also comes with metadata support built-in, meaning that you can define key/value pairs at the top of any Markdown document, which will then be automatically parsed into a Swift dictionary.

To take advantage of that feature, call the `parse` method on `MarkdownParser`, which gives you a `Markdown` value that both contains any metadata found within the parsed Markdown string, as well as its HTML representation:

```swift
let markdown: String = ...
let parser = MarkdownParser()
let result = parser.parse(markdown)

let dateString = result.metadata["date"]
let html = result.html
```

To define metadata values within a Markdown document, use the following syntax:

```
---
keyA: valueA
keyB: valueB
---

Markdown text...
```

The above format is also supported by many different Markdown editors and other tools, even though it’s not part of the [original Markdown spec](https://daringfireball.net/projects/markdown).

## Powerful customization

Besides its [built-in parsing rules](#markdown-syntax-supported), which aims to cover the most common features found in the various flavors of Markdown, you can also customize how Ink performs its parsing through the use of *modifiers*.

A modifier is defined using the `Modifier` type, and is associated with a given `Target`, which determines the kind of Markdown fragments that it will be used for. For example, here’s how an H3 tag could be added before each code block:

```swift
var parser = MarkdownParser()

let modifier = Modifier(target: .codeBlocks) { html, markdown in
    return "<h3>This is a code block:</h3>" + html
}

parser.addModifier(modifier)

let markdown: String = ...
let html = parser.html(from: markdown)
```

Modifiers are passed both the HTML that Ink generated for the given fragment, and its raw Markdown representation as well — both of which can be used to determine how each fragment should be customized.

## Performance built-in

Ink was designed to be as fast and efficient as possible, to enable hundreds of full-length Markdown articles to be parsed in a matter of seconds, while still offering a fully customizable API as well. Two key characteristics make this possible:

1. Ink aims to get as close to `O(N)` complexity as possible, by minimizing the amount of times it needs to read the Markdown strings that are passed to it, and by optimizing its HTML rendering to be completely linear. While *true* `O(N)` complexity is impossible to achieve when it comes to Markdown parsing, because of its very flexible syntax, the goal is to come as close to that target as possible.
2. A high degree of memory efficiency is achieved thanks to Swift’s powerful `String` API, which Ink makes full use of — by using string indexes, ranges and substrings, rather than performing unnecessary string copying between its various operations.

## System requirements

To be able to successfully use Ink, make sure that your system has Swift version 5.2 (or later) installed. If you’re using a Mac, also make sure that `xcode-select` is pointed at an Xcode installation that includes the required version of Swift, and that you’re running macOS Catalina (10.15) or later.

Please note that Ink **does not** officially support any form of beta software, including beta versions of Xcode and macOS, or unreleased versions of Swift.

## Installation

Ink is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a project, simply add it as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/johnsundell/ink.git", from: "0.1.0")
    ],
    ...
)
```

Then import Ink wherever you’d like to use it:

```swift
import Ink
```

For more information on how to use the Swift Package Manager, check out [this article](https://www.swiftbysundell.com/articles/managing-dependencies-using-the-swift-package-manager), or [its official documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

## Command line tool

Ink also ships with a simple but useful command line tool that lets you convert Markdown to HTML directly from the command line.

To install it, clone the project and run `make`:

```
$ git clone https://github.com/johnsundell/Ink.git
$ cd Ink
$ make
```

The command line tool will be installed as `ink`, and can be passed Markdown text for conversion into HTML in several ways.

Calling it without arguments will start reading from `stdin` until terminated with `Ctrl+D`:

```
$ ink
```

Markdown text can be piped in when `ink` is called without arguments:

```
$ echo "*Hello World*" | ink
```

A single argument is treated as a filename, and the corresponding file will be parsed:

```
$ ink file.md
```

A Markdown string can be passed directly using the `-m` or `--markdown` flag:

```
$ ink -m "*Hello World*"
```

You can of course also build your own command line tools that utilizes Ink in more advanced ways by importing it as a package.

## Markdown syntax supported

Ink supports the following Markdown features:

- Headings (H1 - H6), using leading pound signs, for example `## H2`.
- Italic text, by surrounding a piece of text with either an asterisk (`*`), or an underscore (`_`). For example `*Italic text*`.
- Bold text, by surrounding a piece of text with either two asterisks (`**`), or two underscores (`__`). For example `**Bold text**`.
- Text strikethrough, by surrounding a piece of text with two tildes (`~~`), for example `~~Strikethrough text~~`.
- Inline code, marked with a backtick on either site of the code.
- Code blocks, marked with three or more backticks both above and below the block.
- Links, using the following syntax: `[Title](url)`.
- Images, using the following syntax: `![Alt text](image-url)`.
- Both images and links can also use reference URLs, which can be defined anywhere in a Markdown document using this syntax: `[referenceName]: url`.
- Both ordered lists (using numbers followed by a period (`.`) or right parenthesis (`)`) as bullets) and unordered lists (using either a dash (`-`), plus (`+`), or asterisk (`*`) as bullets) are supported.
- Ordered lists start from the index of the first entry
- Nested lists are supported as well, by indenting any part of a list that should be nested within its parent.
- Horizontal lines can be placed using either three asterisks (`***`) or three dashes (`---`) on a new line.
- HTML can be inlined both at the root level, and within text paragraphs.
- Blockquotes can be created by placing a greater-than arrow at the start of a line, like this: `> This is a blockquote`.
- Tables can be created using the following syntax (the line consisting of dashes (`-`) can be omitted to create a table without a header row):
```
| Header | Header 2 |
| ------ | -------- |
| Row 1  | Cell 1   |
| Row 2  | Cell 2   |
```
- LaTeX like equation support. As dollar signs can be found quite commonly on articles (and the slash character is already the escape character), TeX-like equation input is not supported. Note that Ink does _not_ render math equations. You need another library for that, like [KaTeX](https://katex.org) or [MathJax](https://www.mathjax.org). There are two equation modes:
  1. Inline mode equations: `\(x^2 + 5\)`
  2. Display mode equations:  `\[z^2 + 5\]`

Please note that, being a very young implementation, Ink does not fully support all Markdown specs, such as [CommonMark](https://commonmark.org). Ink definitely aims to cover as much ground as possible, and to include support for the most commonly used Markdown features, but if complete CommonMark compatibility is what you’re looking for — then you might want to check out tools like [CMark](https://github.com/commonmark/cmark).

## Internal architecture

Ink uses a highly modular [rule-based](https://www.swiftbysundell.com/articles/rule-based-logic-in-swift) internal architecture, to enable new rules and formatting options to be added without impacting the system as a whole.

Each Markdown fragment is individually parsed and rendered by a type conforming to the internal `Readable` and `HTMLConvertible` protocols — such as `FormattedText`, `List`, and `Image`.

To parse a part of a Markdown document, each fragment type uses a `Reader` instance to read the Markdown string, and to make assertions about its structure. Errors are [used as control flow](https://www.swiftbysundell.com/articles/using-errors-as-control-flow-in-swift) to signal whether a parsing operation was successful or not, which in turn enables the parent context to decide whether to advance the current `Reader` instance, or whether to rewind it.

A good place to start exploring Ink’s implementation is to look at the main `MarkdownParser` type’s `parse` method, and to then dive deeper into the various `Fragment` implementations, and the `Reader` type.

## Credits

Ink was originally written by [John Sundell](https://twitter.com/johnsundell) as part of the Publish suite of static site generation tools, which is used to build and generate [Swift by Sundell](https://swiftbysundell.com). The other tools that make up the Publish suite will also be open sourced soon.

The Markdown format was created by [John Gruber](https://twitter.com/gruber). You can find [more information about it here](https://daringfireball.net/projects/markdown).

## Contributions and support

Ink is developed completely in the open, and your contributions are more than welcome.

Before you start using Ink in any of your projects, it’s highly recommended that you spend a few minutes familiarizing yourself with its documentation and internal implementation, so that you’ll be ready to tackle any issues or edge cases that you might encounter.

Since this is a very young project, it’s likely to have many limitations and missing features, which is something that can really only be discovered and addressed as more people start using it. While Ink is used in production to render all of [Swift by Sundell](https://swiftbysundell.com), it’s recommended that you first try it out for your specific use case, to make sure it supports the features that you need.

This project does not come with GitHub Issues-based support, and users are instead encouraged to become active participants in its continued development — by fixing any bugs that they encounter, or by improving the documentation wherever it’s found to be lacking.

If you wish to make a change, [open a Pull Request](https://github.com/JohnSundell/Ink/pull/new) — even if it just contains a draft of the changes you’re planning, or a test that reproduces an issue — and we can discuss it further from there.

Hope you’ll enjoy using **Ink**!
