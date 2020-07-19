/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal protocol HTMLConvertible {
    func html(usingReferences references: NamedReferenceCollection,
              modifiers: ModifierCollection) -> String
}

extension HTMLConvertible where Self: Modifiable {
    func html(usingReferences references: NamedReferenceCollection,
              rawString: Substring,
              applyingModifiers modifiers: ModifierCollection) -> String {
        var html = self.html(usingReferences: references,
                             modifiers: modifiers)

        modifiers.applyModifiers(for: modifierTarget) { modifier in
            html = modifier.closure((html, rawString))
        }

        return html
    }
}
