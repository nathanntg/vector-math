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
        self.memory = UnsafeMutablePointer<T>.allocate(capacity: length)
        self.memory.initialize(from: memory.memory, count: length)
    }
    
    init(unfilledOfLength length: Int) {
        self.length = length
        self.memory = UnsafeMutablePointer<T>.allocate(capacity: length)
    }
    
    init(unfilledOfLength length: Int, withAlignment align: Int) {
        // alignment: MemoryLayout<T>.alignment
        
        // allocate alligned memory
        let ptr = UnsafeMutableRawPointer.allocate(bytes: length * MemoryLayout<T>.size, alignedTo: align)
        
        // store pointer
        self.length = length
        self.memory = ptr.bindMemory(to: T.self, capacity: length)
    }
    
    deinit {
        memory.deinitialize(count: length)
        memory.deallocate(capacity: length)
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
