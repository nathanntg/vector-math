//
//  VectorMemory.swift
//  VectorMath
//
//  Created by Nathan Perkins on 8/26/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation

public protocol VectorMemory: Vector
{
    init(copyFromPointer ptr: UnsafePointer<Element>, ofLength length: Index)
    // init(atPointer ptr: UnsafeMutablePointer<Element>, ofLength length: Index) // UNSAFE
    
    var unsafePointer: UnsafeBufferPointer<Element> { get }
    var pointer: UnsafeBufferPointer<Element> { mutating get }
}
