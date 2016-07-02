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
    
    // used internally to optimize addition / subtraction (skip copy)
    internal init(unfilledOfLength length: Index) {
        precondition(length >= 0, "Length must be positive.")
        
        memory = ManagedMemory<Element>(unfilledOfLength: length)
    }
    
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
        let _ = withUnsafePointer(&elements[0]) {
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
    // optimization: rather than ensuringUniqueness, offer two code paths depending on whether
    // the memory is uniquely referenced or not
    
    mutating public func inPlaceNegate() {
        // copy before write
        ensureUnique()
        
        // perform negation
        vDSP_vnegD(memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceAddScalar(_ scalar: Element) {
        var scalar = scalar
        
        if isUniquelyReferencedNonObjC(&memory) {
            // perform addition
            vDSP_vsaddD(memory[0], 1, &scalar, memory[0], 1, vDSP_Length(memory.length))
        }
        else {
            // copy on write
            let old = memory
            memory = ManagedMemory<Element>(unfilledOfLength: old.length)
            
            // perform addition
            vDSP_vsaddD(old[0], 1, &scalar, memory[0], 1, vDSP_Length(memory.length))
        }
    }
    
    mutating public func inPlaceAddVector(_ vector: VectorDouble) {
        // must have matching lengths
        ensureSameLength(vector)
        
        if isUniquelyReferencedNonObjC(&memory) {
            // perform addition
            vDSP_vaddD(memory[0], 1, vector.memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
        }
        else {
            // copy on write
            let old = memory
            memory = ManagedMemory<Element>(unfilledOfLength: old.length)
            
            // perform addition
            vDSP_vaddD(old[0], 1, vector.memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
        }
    }
    
    mutating public func inPlaceSubtractScalar(_ scalar: Element) {
        // no vDSP subtraction
        inPlaceAddScalar(0 - scalar)
    }
    
    mutating public func inPlaceSubtractVector(_ vector: VectorDouble) {
        // must have matching lengths
        ensureSameLength(vector)
        
        if isUniquelyReferencedNonObjC(&memory) {
            // perform addition
            vDSP_vsubD(memory[0], 1, vector.memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
        }
        else {
            // copy on write
            let old = memory
            memory = ManagedMemory<Element>(unfilledOfLength: old.length)
            
            // perform addition
            vDSP_vsubD(old[0], 1, vector.memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
        }
    }
    
    mutating public func inPlaceMultiplyScalar(_ scalar: Element) {
        var scalar = scalar
        
        if isUniquelyReferencedNonObjC(&memory) {
            // perform addition
            vDSP_vsmulD(memory[0], 1, &scalar, memory[0], 1, vDSP_Length(memory.length))
        }
        else {
            // copy on write
            let old = memory
            memory = ManagedMemory<Element>(unfilledOfLength: old.length)
            
            // perform addition
            vDSP_vsmulD(old[0], 1, &scalar, memory[0], 1, vDSP_Length(memory.length))
        }
    }
    
    mutating public func inPlaceMultiplyVector(_ vector: VectorDouble) {
        // must have matching lengths
        ensureSameLength(vector)
        
        if isUniquelyReferencedNonObjC(&memory) {
            // perform addition
            vDSP_vmulD(memory[0], 1, vector.memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
        }
        else {
            // copy on write
            let old = memory
            memory = ManagedMemory<Element>(unfilledOfLength: old.length)
            
            // perform addition
            vDSP_vmulD(old[0], 1, vector.memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
        }
    }
    
    mutating public func inPlaceDivideScalar(_ scalar: Element) {
        var scalar = scalar
        
        if isUniquelyReferencedNonObjC(&memory) {
            // perform addition
            vDSP_vsdivD(memory[0], 1, &scalar, memory[0], 1, vDSP_Length(memory.length))
        }
        else {
            // copy on write
            let old = memory
            memory = ManagedMemory<Element>(unfilledOfLength: old.length)
            
            // perform addition
            vDSP_vsdivD(old[0], 1, &scalar, memory[0], 1, vDSP_Length(memory.length))
        }
    }
    
    mutating public func inPlaceDivideVector(_ vector: VectorDouble) {
        // must have matching lengths
        ensureSameLength(vector)
        
        if isUniquelyReferencedNonObjC(&memory) {
            // perform addition
            vDSP_vdivD(vector.memory[0], 1, memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
        }
        else {
            // copy on write
            let old = memory
            memory = ManagedMemory<Element>(unfilledOfLength: old.length)
            
            // perform addition
            vDSP_vdivD(vector.memory[0], 1, old[0], 1, memory[0], 1, vDSP_Length(memory.length))
        }
    }
    
    // NON IN-PLACE OPERATORS
    // Vector provides default implementations that use a copy, then the in place operator
    // directly implementing these produce about a ~15% performance benefit
    
    public func addScalar(_ scalar: Element) -> VectorDouble {
        // create return object
        let ret = VectorDouble(unfilledOfLength: memory.length)
        
        // perform addition
        var scalar = scalar
        vDSP_vsaddD(memory[0], 1, &scalar, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func addVector(_ vector: VectorDouble) -> VectorDouble {
        // must have matching lengths
        ensureSameLength(vector)
        
        // create return object
        let ret = VectorDouble(unfilledOfLength: memory.length)
        
        // perform addition
        vDSP_vaddD(memory[0], 1, vector.memory[0], 1, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func subtractScalar(_ scalar: Element) -> VectorDouble {
        // no vDSP subtraction
        return addScalar(0 - scalar)
    }
    
    public func subtractVector(_ vector: VectorDouble) -> VectorDouble {
        // must have matching lengths
        ensureSameLength(vector)
        
        // create return object
        let ret = VectorDouble(unfilledOfLength: memory.length)
        
        // perform addition
        vDSP_vsubD(vector.memory[0], 1, memory[0], 1, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func multiplyScalar(_ scalar: Element) -> VectorDouble {
        // create return object
        let ret = VectorDouble(unfilledOfLength: memory.length)
        
        // perform addition
        var scalar = scalar
        vDSP_vsmulD(memory[0], 1, &scalar, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func multiplyVector(_ vector: VectorDouble) -> VectorDouble {
        // must have matching lengths
        ensureSameLength(vector)
        
        // create return object
        let ret = VectorDouble(unfilledOfLength: memory.length)
        
        // perform addition
        vDSP_vmulD(memory[0], 1, vector.memory[0], 1, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func divideScalar(_ scalar: Element) -> VectorDouble {
        // create return object
        let ret = VectorDouble(unfilledOfLength: memory.length)
        
        // perform addition
        var scalar = scalar
        vDSP_vsdivD(memory[0], 1, &scalar, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func divideVector(_ vector: VectorDouble) -> VectorDouble {
        // must have matching lengths
        ensureSameLength(vector)
        
        // create return object
        let ret = VectorDouble(unfilledOfLength: memory.length)
        
        // perform addition
        vDSP_vdivD(vector.memory[0], 1, memory[0], 1, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
}

