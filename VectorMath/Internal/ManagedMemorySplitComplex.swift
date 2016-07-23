//
//  ManagedMemorySplitComplex.swift
//  VectorMath
//
//  Created by Nathan Perkins on 7/22/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation
import Accelerate

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
