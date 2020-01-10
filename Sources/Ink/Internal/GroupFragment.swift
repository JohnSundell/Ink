/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct ParsedFragment {
    var fragment: Fragment
    var rawString: Substring
}

internal protocol GroupFragment: Fragment {
    var fragments: [ParsedFragment] { get }
}

extension GroupFragment {
    func html(usingURLs urls: NamedURLCollection, modifiers: ModifierCollection) -> String {
        return fragments.reduce(into: "") { result, wrapper in
            let html = wrapper.fragment.html(
                usingURLs: urls,
                rawString: wrapper.rawString,
                applyingModifiers: modifiers
            )

            result.append(html)
        }
    }
    
    func plainText() -> String {
        return fragments.reduce(into: "") { result, wrapper in
            let text = wrapper.fragment.plainText()
            result.append(text)
        }
    }
}
