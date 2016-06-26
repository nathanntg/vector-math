//
//  VectorFloat.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/24/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation
import Accelerate

public struct VectorFloat: Vector
{
    public typealias IndexType = Int
    public typealias ElementType = Float
    
    private var memory: ManagedMemory<ElementType>
    
    // TODO: INVESTIGATE if there is a performance penalty for this, or if it just gets inlined
    public var count: Int {
        get {
            return memory.length
        }
    }
    public var length: Int {
        get {
            return memory.length
        }
    }
    
    // INITIALIZATION
    
    public init(zerosOfLength length: IndexType) {
        memory = ManagedMemory<Float>(unfilledOfLength: length)
        vDSP_vclr(memory[0], 1, vDSP_Length(length))
    }
    
    public init(copyOf vector: VectorFloat) {
        // will copy on write
        memory = vector.memory
    }
    
    
    // PRIVATE
    
    mutating private func ensureUnique() {
        if !isUniquelyReferencedNonObjC(&memory) {
            memory = memory.copy()
        }
    }
    
    // ACCESS
    
    public subscript(index: IndexType) -> ElementType {
        get {
            return memory[index]
        }
        set {
            memory[index] = newValue
        }
    }
    
    // OPERATORS
    
    mutating public func inPlaceAddScalar(_ scalar: ElementType) {
        // copy before write
        ensureUnique()
        
        // perform add
        var scalar = scalar
        vDSP_vsadd(memory[0], 1, &scalar, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceAddVector(_ vector: VectorFloat) {
        // must have matching lengths
        precondition(memory.length == vector.memory.length, "Vector lengths do not match (\(memory.length) and \(vector.memory.length))")
        
        // copy before write
        ensureUnique()
        
        // perform addition
        vDSP_vadd(memory[0], 1, vector.memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
    }
}

