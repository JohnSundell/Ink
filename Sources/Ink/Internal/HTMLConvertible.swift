/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal protocol HTMLConvertible {
    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String
}

extension HTMLConvertible where Self: Modifiable {
    func html(usingURLs urls: NamedURLCollection,
              rawString: Substring,
              applyingModifiers modifiers: ModifierCollection) -> String {
        var html = self.html(usingURLs: urls, modifiers: modifiers)

        var plainText: String? = nil
        if let plainTextConvertible = self as? PlainTextConvertible {
          plainText = plainTextConvertible.plainText()
        }

        modifiers.applyModifiers(for: modifierTarget) { modifier in
            html = modifier.closure((html, plainText, rawString))
        }

        return html
    }
}
