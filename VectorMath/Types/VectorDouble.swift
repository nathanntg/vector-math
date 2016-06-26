//
//  VectorDouble.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/26/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation
import Accelerate

public struct VectorDouble: Vector
{
    public typealias Index = Int
    public typealias Element = Double
    
    private var memory: ManagedMemory<Element>
    
    // TODO: INVESTIGATE if there is a performance penalty for this, or if it just gets inlined
    public var count: Index {
        get {
            return memory.length
        }
    }
    public var length: Index {
        get {
            return memory.length
        }
    }
    
    // INITIALIZATION
    
    public init(zerosOfLength length: Index) {
        precondition(length >= 0, "Length must be positive.")
        
        memory = ManagedMemory<Element>(unfilledOfLength: length)
        vDSP_vclrD(memory[0], 1, vDSP_Length(length))
    }
    
    public init(copyOf vector: VectorDouble) {
        // will copy on write
        memory = vector.memory
    }
    
    public init(fromArray elements: [Element]) {
        // initialize memory
        memory = ManagedMemory<Element>(unfilledOfLength: elements.count)
        
        // copy elements
        var elements = elements
        withUnsafePointer(&elements[0]) {
            memcpy(memory[0], $0, sizeof(Element) * elements.count)
        }
    }
    
    // PRIVATE
    
    mutating private func ensureUnique() {
        if !isUniquelyReferencedNonObjC(&memory) {
            memory = memory.copy()
        }
    }
    
    private func ensureSameLength(_ vector: VectorDouble) {
        // must have matching lengths
        precondition(memory.length == vector.memory.length, "Vector lengths do not match (\(memory.length) and \(vector.memory.length))")
    }
    
    // ACCESS
    
    public subscript(index: Index) -> Element {
        get {
            return memory[index]
        }
        set {
            // copy before write
            ensureUnique()
            
            // assign
            memory[index] = newValue
        }
    }
    
    // SUMMARIZE
    
    public func sum() -> Element {
        var ret: Element = 0
        vDSP_sveD(memory[0], 1, &ret, vDSP_Length(memory.length))
        return ret
    }
    
    public func mean() -> Element {
        var ret: Element = 0
        vDSP_meanvD(memory[0], 1, &ret, vDSP_Length(memory.length))
        return ret
    }
    
    public func min() -> Element {
        var ret: Element = 0
        vDSP_minvD(memory[0], 1, &ret, vDSP_Length(memory.length))
        return ret
    }
    
    public func max() -> Element {
        var ret: Element = 0
        vDSP_maxvD(memory[0], 1, &ret, vDSP_Length(memory.length))
        return ret
    }
    
    // IN-PLACE OPERATORS
    
    mutating public func inPlaceNegate() {
        // copy before write
        ensureUnique()
        
        // perform negation
        vDSP_vnegD(memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceAddScalar(_ scalar: Element) {
        // copy before write
        ensureUnique()
        
        // perform add
        var scalar = scalar
        vDSP_vsaddD(memory[0], 1, &scalar, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceAddVector(_ vector: VectorDouble) {
        // must have matching lengths
        ensureSameLength(vector)
        
        // copy before write
        ensureUnique()
        
        // perform addition
        vDSP_vaddD(memory[0], 1, vector.memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceSubtractScalar(_ scalar: Element) {
        // no vDSP subtraction
        inPlaceAddScalar(0 - scalar)
    }
    
    mutating public func inPlaceSubtractVector(_ vector: VectorDouble) {
        // must have matching lengths
        ensureSameLength(vector)
        
        // copy before write
        ensureUnique()
        
        // perform addition
        vDSP_vsubD(vector.memory[0], 1, memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
    }
    
}

