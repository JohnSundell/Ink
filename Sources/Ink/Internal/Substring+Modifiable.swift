//
//  Substring+Modifiable.swift
//  
//
//  Created by Ben Syverson on 2020/01/29.
//

extension Substring: HTMLConvertible {
    func html(usingURLs urls: NamedURLCollection, modifiers: ModifierCollection) -> String {
        return String(self)
    }
}

extension Substring: PlainTextConvertible {
    func plainText() -> String {
        return String(self)
    }
}

extension Substring: Modifiable {
    var modifierTarget: Modifier.Target { .text }
}
