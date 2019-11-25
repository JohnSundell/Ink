/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal struct NamedURLCollection {
    private let urlsByName: [Substring : URL]

    init(urlsByName: [Substring : URL]) {
        self.urlsByName = urlsByName
    }

    func url(named name: Substring) -> URL? {
        urlsByName[name]
    }
}
