//
//  Attribute.swift
//  
//
//  Created by Sven A. Schmidt on 22/02/2020.
//


internal struct Attribute: HTMLConvertible {
    var key: String
    var value: String

    init?(_ rawValue: String) {
        let pair = rawValue.split(separator: "=").map(String.init)
        guard pair.count == 2 else { return nil }
        key = pair[0]
        value = pair[1]
    }

    func html(usingURLs urls: NamedURLCollection, modifiers: ModifierCollection) -> String {
        "\(key)=\"\(value)\""
    }
}
