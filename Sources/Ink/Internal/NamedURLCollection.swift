/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct NamedURLCollection {
    private let urlsByName: [String : URLDeclaration]

    init(urlsByName: [String : URLDeclaration]) {
        self.urlsByName = urlsByName
    }

    func url(named name: Substring) -> URLDeclaration? {
        urlsByName[name.lowercased()]
    }
}
