//
//  ManagedMemorySplitComplexDouble.swift
//  VectorMath
//
//  Created by Nathan Perkins on 7/22/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation
import Accelerate

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
