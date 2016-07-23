//
//  VectorArithmetic.swift
//  VectorMath
//
//  Created by Nathan Perkins on 7/22/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

public protocol VectorArithmetic: Vector
{
    // IN-PLACE OPERATORS
    
    mutating func inPlaceNegate()
    
    mutating func inPlaceAddScalar(_ scalar: Element)
    mutating func inPlaceAddVector(_ vector: Self)
    
    mutating func inPlaceSubtractScalar(_ scalar: Element)
    mutating func inPlaceSubtractVector(_ vector: Self)
    
    mutating func inPlaceMultiplyScalar(_ scalar: Element)
    mutating func inPlaceMultiplyVector(_ vector: Self)
    
    mutating func inPlaceDivideScalar(_ scalar: Element)
    mutating func inPlaceDivideVector(_ vector: Self)
    
    // OPERATORS
    
    func negate() -> Self
    
    func addScalar(_ scalar: Element) -> Self
    func addVector(_ vector: Self) -> Self
    
    func subtractScalar(_ scalar: Element) -> Self
    func subtractVector(_ vector: Self) -> Self
    
    func multiplyScalar(_ scalar: Element) -> Self
    func multiplyVector(_ vector: Self) -> Self
    
    func divideScalar(_ scalar: Element) -> Self
    func divideVector(_ vector: Self) -> Self
}

extension VectorArithmetic {
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
    
    public func multiplyScalar(_ scalar: Element) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceMultiplyScalar(scalar)
        return ret
    }
    
    public func multiplyVector(_ vector: Self) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceMultiplyVector(vector)
        return ret
    }
    
    public func divideScalar(_ scalar: Element) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceDivideScalar(scalar)
        return ret
    }
    
    public func divideVector(_ vector: Self) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceDivideVector(vector)
        return ret
    }
}

// TODO: implement equatable

public func +=<T: VectorArithmetic, U where T.Element == U>(lhs: inout T, rhs: U) {
    lhs.inPlaceAddScalar(rhs)
}

public func +=<T: VectorArithmetic>(lhs: inout T, rhs: T) {
    lhs.inPlaceAddVector(rhs)
}

public func -=<T: VectorArithmetic, U where T.Element == U>(lhs: inout T, rhs: U) {
    lhs.inPlaceSubtractScalar(rhs)
}

public func -=<T: VectorArithmetic>(lhs: inout T, rhs: T) {
    lhs.inPlaceSubtractVector(rhs)
}

public func *=<T: VectorArithmetic, U where T.Element == U>(lhs: inout T, rhs: U) {
    lhs.inPlaceMultiplyScalar(rhs)
}

public func *=<T: VectorArithmetic>(lhs: inout T, rhs: T) {
    lhs.inPlaceMultiplyVector(rhs)
}

public func /=<T: VectorArithmetic, U where T.Element == U>(lhs: inout T, rhs: U) {
    lhs.inPlaceDivideScalar(rhs)
}

public func /=<T: VectorArithmetic>(lhs: inout T, rhs: T) {
    lhs.inPlaceDivideVector(rhs)
}

public func +<T: VectorArithmetic, U where T.Element == U>(lhs: T, rhs: U) -> T {
    return lhs.addScalar(rhs)
}

public func +<T: VectorArithmetic, U where T.Element == U>(lhs: U, rhs: T) -> T {
    return rhs.addScalar(lhs)
}

public func +<T: VectorArithmetic>(lhs: T, rhs: T) -> T {
    return lhs.addVector(rhs)
}

public func -<T: VectorArithmetic, U where T.Element == U>(lhs: T, rhs: U) -> T {
    return lhs.subtractScalar(rhs)
}

public func -<T: VectorArithmetic, U where T.Element == U>(lhs: U, rhs: T) -> T {
    return rhs.negate() + lhs
}

public func -<T: VectorArithmetic>(lhs: T, rhs: T) -> T {
    return lhs.subtractVector(rhs)
}

public func *<T: VectorArithmetic, U where T.Element == U>(lhs: T, rhs: U) -> T {
    return lhs.multiplyScalar(rhs)
}

public func *<T: VectorArithmetic, U where T.Element == U>(lhs: U, rhs: T) -> T {
    return rhs.multiplyScalar(lhs)
}

public func *<T: VectorArithmetic>(lhs: T, rhs: T) -> T {
    return lhs.multiplyVector(rhs)
}

public func /<T: VectorArithmetic, U where T.Element == U>(lhs: T, rhs: U) -> T {
    return lhs.divideScalar(rhs)
}

public func /<T: VectorArithmetic>(lhs: T, rhs: T) -> T {
    return lhs.divideVector(rhs)
}
