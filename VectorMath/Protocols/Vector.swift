//
//  Vector.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/24/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation

public protocol Vector
{
    associatedtype IndexType
    associatedtype ElementType
    
    var count: Int { get }
    var length: Int { get }
    
    // INITIALIZERS
    init(zerosOfLength length: IndexType)
    init(copyOf vector: Self)
    
    // ACCESS
    subscript(index: IndexType) -> ElementType { get set }
    
    // IN-PLACE OPERATORS
    mutating func inPlaceAddScalar(_ scalar: ElementType)
    mutating func inPlaceAddVector(_ vector: Self)
}

public func +=<T: Vector, U where T.ElementType == U>(lhs: inout T, rhs: U) {
    lhs.inPlaceAddScalar(rhs)
}

public func +=<T: Vector>(lhs: inout T, rhs: T) {
    lhs.inPlaceAddVector(rhs)
}
