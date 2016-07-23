//
//  Vector.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/24/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation

public protocol Vector: RandomAccessCollection, ArrayLiteralConvertible, CustomDebugStringConvertible
{
    associatedtype Index
    associatedtype Element
    
    var count: Index { get }
    var length: Index { get }
    
    // INITIALIZERS
    init(zerosOfLength length: Index)
    init(copyOf vector: Self)
    init(fromArray array: [Element])
    init(arrayLiteral elements: Element...)
    
    // ACCESS
    subscript(index: Index) -> Element { get set }
}

extension Vector where Index: Integer {
    public var startIndex: Index {
        return 0
    }
    
    public var endIndex: Index {
        return count
    }
    
    public func index(before i: Index) -> Index {
        return i - 1
    }
    
    public func index(after i: Index) -> Index {
        return i + 1
    }
}

extension Vector {
    public init(arrayLiteral elements: Element...) {
        self.init(fromArray: elements)
    }
}

extension Vector where Element: CustomStringConvertible {
    public var debugDescription: String {
        let strings = map {
            return "\($0)"
        }
        
        let string = strings.joined(separator: ", ")
        
        return "[\(string)]"
    }
}

public func ==<T: Vector where T.Element: Equatable, T.Index == Int>(lhs: T, rhs: T) -> Bool {
    if rhs.length != lhs.length {
        return false
    }
    
    for i in 0..<rhs.length {
        if rhs[i] != lhs[i] {
            return false
        }
    }
    
    return true
}
