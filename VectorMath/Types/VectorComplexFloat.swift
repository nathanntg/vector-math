//
//  VectorComplexFloat.swift
//  VectorMath
//
//  Created by Nathan Perkins on 7/21/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation
import Accelerate

public struct VectorComplexFloat: Vector
{
    public typealias Index = Int
    public typealias Element = ComplexFloat
    
    private var memory: ManagedMemorySplitComplex
    
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
        
        memory = ManagedMemorySplitComplex(unfilledOfLength: length)
    }
    
    public init(zerosOfLength length: Index) {
        precondition(length >= 0, "Length must be positive.")
        
        memory = ManagedMemorySplitComplex(unfilledOfLength: length)
        vDSP_vclr(memory.real[0], 1, vDSP_Length(length))
        vDSP_vclr(memory.imaginary[0], 1, vDSP_Length(length))
    }
    
    public init(copyOf vector: VectorComplexFloat) {
        // will copy on write
        memory = vector.memory
    }
    
    public init(fromArray elements: [Element]) {
        // initialize memory
        memory = ManagedMemorySplitComplex(unfilledOfLength: elements.count)
        
        // TODO: benchmark against some sort of vDSP copy function
        // compiler may correctly optimize this?
        
        for (i, el) in elements.enumerated() {
            memory.real[i] = el.real
            memory.imaginary[i] = el.imag
        }
    }
    
    // PRIVATE
    
    mutating private func ensureUnique() {
        if !isUniquelyReferencedNonObjC(&memory) {
            memory = memory.copy()
        }
    }
    
    mutating private func ensureUniqueWritableAndReturnReadable() -> ManagedMemorySplitComplex {
        if isUniquelyReferencedNonObjC(&memory) {
            // uniquely referenced memory, use the same pointer
            return memory
        }
        else {
            // allocate new memory
            let old = memory
            memory = ManagedMemorySplitComplex(unfilledOfLength: old.length)
            return old
        }
    }
    
    private func ensureSameLength(_ vector: VectorComplexFloat) {
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
    
    // IN-PLACE OPERATORS
    // optimization: rather than ensuringUniqueness, offer two code paths depending on whether
    // the memory is uniquely referenced or not
    
    mutating public func inPlaceNegate() {
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform negation
        var ptrRead = read.complex
        var ptrWrite = memory.complex
        vDSP_zvneg(&ptrRead, 1, &ptrWrite, 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceAddScalar(_ scalar: Element) {
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform addition
        var scalarReal = scalar.real
        var scalarImaginary = scalar.imag
        vDSP_vsadd(read.real[0], 1, &scalarReal, memory.real[0], 1, vDSP_Length(memory.length))
        vDSP_vsadd(read.imaginary[0], 1, &scalarImaginary, memory.imaginary[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceAddVector(_ vector: VectorComplexFloat) {
        // must have matching lengths
        ensureSameLength(vector)
        
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform addition
        var ptrRead = read.complex
        var ptrVector = vector.memory.complex
        var ptrWrite = memory.complex
        vDSP_zvadd(&ptrRead, 1, &ptrVector, 1, &ptrWrite, 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceSubtractScalar(_ scalar: Element) {
        // no vDSP subtraction
        inPlaceAddScalar(Element(real: 0 - scalar.real, imag: 0 - scalar.imag))
    }
    
    mutating public func inPlaceSubtractVector(_ vector: VectorComplexFloat) {
        // must have matching lengths
        ensureSameLength(vector)
        
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform subtraction
        var ptrRead = read.complex
        var ptrVector = vector.memory.complex
        var ptrWrite = memory.complex
        vDSP_zvsub(&ptrRead, 1, &ptrVector, 1, &ptrWrite, 1, vDSP_Length(memory.length))
    }
}
