/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

func require(_ bool: Bool) throws {
    struct RequireError: Error {}
    guard bool else { throw RequireError() }
}
