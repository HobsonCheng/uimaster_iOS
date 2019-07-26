import Foundation

// https://github.com/apple/swift-evolution/blob/master/proposals/0121-remove-optional-comparison-operators.md
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
public func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (tempFirst?, tempScond?): return tempFirst < tempScond
    case (nil, _?): return true
    default: return false }
}

public func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (tempFirst?, tempSecond?):
        return tempFirst > tempSecond
    default:
        return rhs < lhs
    }
}

public func == <T: Equatable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (tempFirst?, tempSecond?):
        return tempFirst == tempSecond
    case (nil, nil):
        return true
    default:
        return false
    }
}
