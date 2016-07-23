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
    internal let memory: UnsafeMutablePointer<T>
    
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
        let ret = posix_memalign(&p, align, length * sizeof(T.self))
        
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
