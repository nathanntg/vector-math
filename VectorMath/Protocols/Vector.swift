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
    
    // IN-PLACE OPERATORS
    
    mutating func inPlaceNegate()
    
    mutating func inPlaceAddScalar(_ scalar: Element)
    mutating func inPlaceAddVector(_ vector: Self)
    
    mutating func inPlaceSubtractScalar(_ scalar: Element)
    mutating func inPlaceSubtractVector(_ vector: Self)
    
    // OPERATORS
    
    func negate() -> Self
    
    func addScalar(_ scalar: Element) -> Self
    func addVector(_ vector: Self) -> Self
    
    func subtractScalar(_ scalar: Element) -> Self
    func subtractVector(_ vector: Self) -> Self
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

extension Vector where Element: CustomDebugStringConvertible {
    public var debugDescription: String {
        let strings = map {
            return "\($0)"
        }
        
        let string = strings.joined(separator: ", ")
        
        return "[\(string)]"
    }
}

extension Vector {
    public func negate() -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceNegate()
        return ret
    }
    
    public func addScalar(_ scalar: Element) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceAddScalar(scalar)
        return ret
    }
    
    public func addVector(_ vector: Self) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceAddVector(vector)
        return ret
    }
    
    public func subtractScalar(_ scalar: Element) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceSubtractScalar(scalar)
        return ret
    }
    
    public func subtractVector(_ vector: Self) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceSubtractVector(vector)
        return ret
    }
}

// TODO: implement equatable

public func +=<T: Vector, U where T.Element == U>(lhs: inout T, rhs: U) {
    lhs.inPlaceAddScalar(rhs)
}

public func +=<T: Vector>(lhs: inout T, rhs: T) {
    lhs.inPlaceAddVector(rhs)
}

public func -=<T: Vector, U where T.Element == U>(lhs: inout T, rhs: U) {
    lhs.inPlaceSubtractScalar(rhs)
}

public func -=<T: Vector>(lhs: inout T, rhs: T) {
    lhs.inPlaceSubtractVector(rhs)
}

public func +<T: Vector, U where T.Element == U>(lhs: T, rhs: U) -> T {
    return lhs.addScalar(rhs)
}

public func +<T: Vector, U where T.Element == U>(lhs: U, rhs: T) -> T {
    return rhs.addScalar(lhs)
}

public func +<T: Vector>(lhs: T, rhs: T) -> T {
    return lhs.addVector(rhs)
}

public func -<T: Vector, U where T.Element == U>(lhs: T, rhs: U) -> T {
    return lhs.subtractScalar(rhs)
}

public func -<T: Vector, U where T.Element == U>(lhs: U, rhs: T) -> T {
    return rhs.negate() + lhs
}

public func -<T: Vector>(lhs: T, rhs: T) -> T {
    return lhs.subtractVector(rhs)
    
}
