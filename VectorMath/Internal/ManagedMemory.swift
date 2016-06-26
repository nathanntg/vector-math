//
//  ManagedMemory.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/23/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation
import Accelerate

final class ManagedMemory<T>: Memory {
    typealias ElementType = T
    
    let length: Int
    private let memory: UnsafeMutablePointer<T>
    
    init(from memory: ManagedMemory<T>) {
        self.length = memory.length
        self.memory = UnsafeMutablePointer<T>(allocatingCapacity: length)
        self.memory.initializeFrom(memory.memory, count: length)
    }
    
    init(unfilledOfLength length: Int) {
        self.length = length
        self.memory = UnsafeMutablePointer<T>(allocatingCapacity: length)
    }
    
    init(unfilledOfLength length: Int, withAlignment align: Int) {
        // use posix to make aligned memory
        var p: UnsafeMutablePointer<Void>? = nil
        let ret = posix_memalign(&p, align, length * sizeof(T))
        
        // error check
        if ret != noErr {
            let err = String(validatingUTF8: strerror(ret)) ?? "unknown error"
            fatalError("Unable to allocate aligned memory: \(err).")
        }
        
        // store pointer
        self.length = length
        self.memory = UnsafeMutablePointer<T>(p!)
    }
    
    deinit {
        memory.deinitialize(count: length)
        memory.deallocateCapacity(length)
    }
    
    func copy() -> ManagedMemory<T> {
        // init handles copy
        return ManagedMemory<T>(from: self)
    }
    
    subscript(index: Int) -> UnsafeMutablePointer<T> {
        if index == 0 {
            return memory
        }
        
        precondition(index > 0 && index < length, "Index must fall within managed memory.")
        return memory.advanced(by: index)
    }
    
    subscript(index: Int) -> T {
        get {
            precondition(index >= 0 && index < length, "Index must fall within managed memory.")
            return memory[index]
        }
        set {
            precondition(index >= 0 && index < length, "Index must fall within managed memory.")
            memory[index] = newValue
        }
    }
}

final class ManagedMemorySplitComplex: Memory {
    typealias ElementType = DSPComplex
    
    let length: Int
    let real: ManagedMemory<Float>
    let imaginary: ManagedMemory<Float>
    let complex: DSPSplitComplex
    
    init(real: ManagedMemory<Float>, imaginary: ManagedMemory<Float>) {
        precondition(real.length == imaginary.length, "Real and imaginary memory must be the same length.")
        
        self.length = real.length
        self.real = real
        self.imaginary = imaginary
        self.complex = DSPSplitComplex(realp: real[0], imagp: imaginary[0])
    }
    
    init(unfilledOfLength length: Int) {
        self.length = length
        real = ManagedMemory<Float>(unfilledOfLength: length)
        imaginary = ManagedMemory<Float>(unfilledOfLength: length)
        complex = DSPSplitComplex(realp: real[0], imagp: imaginary[0])
    }
    
    init(unfilledOfLength length: Int, withAlignment align: Int) {
        self.length = length
        real = ManagedMemory<Float>(unfilledOfLength: length, withAlignment:  align)
        imaginary = ManagedMemory<Float>(unfilledOfLength: length, withAlignment:  align)
        complex = DSPSplitComplex(realp: real[0], imagp: imaginary[0])
    }
    
    func copy() -> ManagedMemorySplitComplex {
        return ManagedMemorySplitComplex(real: real.copy(), imaginary: imaginary.copy())
    }
    
    subscript(index: Int) -> DSPComplex {
        get {
            precondition(index >= 0 && index < length, "Index must fall within managed memory.")
            return DSPComplex(real: real.memory[index], imag: real.memory[index])
        }
        set {
            precondition(index >= 0 && index < length, "Index must fall within managed memory.")
            real[index] = newValue.real
            imaginary[index] = newValue.imag
        }
    }
}

final class ManagedMemorySplitComplexDouble: Memory {
    typealias ElementType = DSPDoubleComplex
    
    let length: Int
    let real: ManagedMemory<Double>
    let imaginary: ManagedMemory<Double>
    let complex: DSPDoubleSplitComplex
    
    init(real: ManagedMemory<Double>, imaginary: ManagedMemory<Double>) {
        precondition(real.length == imaginary.length, "Real and imaginary memory must be the same length.")
        
        self.length = real.length
        self.real = real
        self.imaginary = imaginary
        self.complex = DSPDoubleSplitComplex(realp: real[0], imagp: imaginary[0])
    }
    
    init(unfilledOfLength length: Int) {
        self.length = length
        real = ManagedMemory<Double>(unfilledOfLength: length)
        imaginary = ManagedMemory<Double>(unfilledOfLength: length)
        complex = DSPDoubleSplitComplex(realp: real[0], imagp: imaginary[0])
    }
    
    init(unfilledOfLength length: Int, withAlignment align: Int) {
        self.length = length
        real = ManagedMemory<Double>(unfilledOfLength: length, withAlignment:  align)
        imaginary = ManagedMemory<Double>(unfilledOfLength: length, withAlignment:  align)
        complex = DSPDoubleSplitComplex(realp: real[0], imagp: imaginary[0])
    }
    
    func copy() -> ManagedMemorySplitComplexDouble {
        return ManagedMemorySplitComplexDouble(real: real.copy(), imaginary: imaginary.copy())
    }
    
    subscript(index: Int) -> DSPDoubleComplex {
        get {
            precondition(index >= 0 && index < length, "Index must fall within managed memory.")
            return DSPDoubleComplex(real: real.memory[index], imag: real.memory[index])
        }
        set {
            precondition(index >= 0 && index < length, "Index must fall within managed memory.")
            real[index] = newValue.real
            imaginary[index] = newValue.imag
        }
    }
}
