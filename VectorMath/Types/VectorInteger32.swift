//
//  VectorInteger32.swift
//  VectorMath
//
//  Created by Nathan Perkins on 7/4/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation
import Accelerate

public struct VectorInteger32: Vector, VectorSummarizable, VectorArithmetic, Equatable
{
    public typealias Index = Int
    public typealias Element = Int32
    
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
        var fill: Int32 = 0
        vDSP_vfilli(&fill, memory[0], 1, vDSP_Length(length))
    }
    
    public init(copyOf vector: VectorInteger32) {
        // will copy on write
        memory = vector.memory
    }
    
    public init(fromArray elements: [Element]) {
        // initialize memory
        memory = ManagedMemory<Element>(unfilledOfLength: elements.count)
        
        // copy elements
        var elements = elements
        let _ = withUnsafePointer(&elements[0]) {
            memcpy(memory[0], $0, sizeof(Element.self) * elements.count)
        }
    }
    
    // PRIVATE
    
    mutating private func ensureUnique() {
        if !isUniquelyReferencedNonObjC(&memory) {
            memory = memory.copy()
        }
    }
    
    // good idea, and well optimized by compiler
    // RISK: not thread safe
    // if old is not uniquely referenced at first, it may be deinit on another thread
    // since this function will not retain it after returning
    //    mutating private func uniquePointerForWriting() -> (read: UnsafePointer<Element>, write: UnsafeMutablePointer<Element>) {
    //        if isUniquelyReferencedNonObjC(&memory) {
    //            // uniquely referenced memory, use the same pointer
    //            let ptr: UnsafeMutablePointer<Element> = memory[0]
    //            return (read: UnsafePointer<Element>(ptr), write: ptr)
    //        }
    //        else {
    //            // allocate new memory
    //            let old = memory
    //            memory = ManagedMemory(unfilledOfLength: old.length)
    //
    //            // get pointers
    //            let ptrOld: UnsafeMutablePointer<Element> = old[0]
    //            let ptrNew: UnsafeMutablePointer<Element> = memory[0]
    //
    //            // return both pointers
    //            return (read: UnsafePointer<Element>(ptrOld), write: ptrNew)
    //        }
    //    }
    
    mutating private func ensureUniqueWritableAndReturnReadable() -> ManagedMemory<Element> {
        if isUniquelyReferencedNonObjC(&memory) {
            // uniquely referenced memory, use the same pointer
            return memory
        }
        else {
            // allocate new memory
            let old = memory
            memory = ManagedMemory(unfilledOfLength: old.length)
            return old
        }
    }
    
    private func ensureSameLength(_ vector: VectorInteger32) {
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
        for v in self {
            ret += v
        }
        return ret
    }
    
    public func mean() -> Element {
        return sum() / Int32(memory.length)
    }
    
    public func min() -> Element {
        return self.min()!
    }
    
    public func max() -> Element {
        return self.max()!
    }
    
    // IN-PLACE OPERATORS
    // optimization: rather than ensuringUniqueness, offer two code paths depending on whether
    // the memory is uniquely referenced or not
    
    mutating public func inPlaceNegate() {
        // copy before write
        ensureUnique()
        
        // perform negation
        for i in 0..<memory.length {
            memory[i] = 0 - memory[i]
        }
    }
    
    mutating public func inPlaceAddScalar(_ scalar: Element) {
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform addition
        var scalar = scalar
        vDSP_vsaddi(read[0], 1, &scalar, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceAddVector(_ vector: VectorInteger32) {
        // must have matching lengths
        ensureSameLength(vector)
        
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform addition
        vDSP_vaddi(read[0], 1, vector.memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceSubtractScalar(_ scalar: Element) {
        // no vDSP subtraction
        inPlaceAddScalar(0 - scalar)
    }
    
    mutating public func inPlaceSubtractVector(_ vector: VectorInteger32) {
        // must have matching lengths
        ensureSameLength(vector)
        
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform subtraction
        for i in 0..<memory.length {
            memory[i] = read[i] - vector.memory[i]
        }
    }
    
    mutating public func inPlaceSubtractFromScalar(_ scalar: Element) {
        // no vDSP subtraction
        inPlaceNegate()
        inPlaceAddScalar(scalar)
    }
    
    mutating public func inPlaceSubtractFromVector(_ vector: VectorInteger32) {
        // must have matching lengths
        ensureSameLength(vector)
        
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform subtraction
        for i in 0..<memory.length {
            memory[i] = vector.memory[i] - read[i]
        }
    }
    
    mutating public func inPlaceMultiplyScalar(_ scalar: Element) {
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform multiplication
        for i in 0..<memory.length {
            memory[i] = read[i] * scalar
        }
    }
    
    mutating public func inPlaceMultiplyVector(_ vector: VectorInteger32) {
        // must have matching lengths
        ensureSameLength(vector)
        
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform multiplication
        for i in 0..<memory.length {
            memory[i] = read[i] * vector.memory[i]
        }
    }
    
    mutating public func inPlaceDivideScalar(_ scalar: Element) {
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform division
        var scalar = scalar
        vDSP_vsdivi(read[0], 1, &scalar, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceDivideVector(_ vector: VectorInteger32) {
        // must have matching lengths
        ensureSameLength(vector)
        
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform division
        vDSP_vdivi(vector.memory[0], 1, read[0], 1, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceDivideIntoScalar(_ scalar: Element) {
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform division
        for i in 0..<memory.length {
            memory[i] = scalar / read[i]
        }
    }
    
    mutating public func inPlaceDivideIntoVector(_ vector: VectorInteger32) {
        // must have matching lengths
        ensureSameLength(vector)
        
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform division
        vDSP_vdivi(read[0], 1, vector.memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
    }
    
    // NON IN-PLACE OPERATORS
    // Vector provides default implementations that use a copy, then the in place operator
    // directly implementing these produce about a ~15% performance benefit
    
    public func negate() -> VectorInteger32 {
        // create return object
        let ret = VectorInteger32(unfilledOfLength: memory.length)
        
        // perform negation
        for i in 0..<memory.length {
            ret.memory[i] = 0 - memory[i]
        }
        return ret
    }
    
    public func addScalar(_ scalar: Element) -> VectorInteger32 {
        // create return object
        let ret = VectorInteger32(unfilledOfLength: memory.length)
        
        // perform addition
        var scalar = scalar
        vDSP_vsaddi(memory[0], 1, &scalar, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func addVector(_ vector: VectorInteger32) -> VectorInteger32 {
        // must have matching lengths
        ensureSameLength(vector)
        
        // create return object
        let ret = VectorInteger32(unfilledOfLength: memory.length)
        
        // perform addition
        vDSP_vaddi(memory[0], 1, vector.memory[0], 1, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func subtractScalar(_ scalar: Element) -> VectorInteger32 {
        // no vDSP subtraction
        return addScalar(0 - scalar)
    }
    
    public func subtractFromScalar(_ scalar: Element) -> VectorInteger32 {
        // no vDSP subtraction
        var ret = negate()
        ret.inPlaceAddScalar(scalar)
        return ret
    }
    
    // potentially implement: public func subtractVector(_ vector: VectorInteger32) -> VectorInteger32
    
    // potentially implement: public func multiplyScalar(_ scalar: Element) -> VectorInteger32
    
    // potentially implement: public func multiplyVector(_ vector: VectorInteger32) -> VectorInteger32
    
    public func divideScalar(_ scalar: Element) -> VectorInteger32 {
        // create return object
        let ret = VectorInteger32(unfilledOfLength: memory.length)
        
        // perform addition
        var scalar = scalar
        vDSP_vsdivi(memory[0], 1, &scalar, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func divideVector(_ vector: VectorInteger32) -> VectorInteger32 {
        // must have matching lengths
        ensureSameLength(vector)
        
        // create return object
        let ret = VectorInteger32(unfilledOfLength: memory.length)
        
        // perform addition
        vDSP_vdivi(vector.memory[0], 1, memory[0], 1, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    // potentially implement: public func divideIntoScalar(_ scalar: Element) -> VectorInteger32
    
    public func divideIntoVector(_ vector: VectorInteger32) -> VectorInteger32 {
        // must have matching lengths
        ensureSameLength(vector)
        
        // create return object
        let ret = VectorInteger32(unfilledOfLength: memory.length)
        
        // perform addition
        vDSP_vdivi(memory[0], 1, vector.memory[0], 1, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
}

