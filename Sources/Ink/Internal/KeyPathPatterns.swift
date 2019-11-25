/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal func ~=<T>(rhs: KeyPath<T, Bool>, lhs: T) -> Bool {
    lhs[keyPath: rhs]
}
