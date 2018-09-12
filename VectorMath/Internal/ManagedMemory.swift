//
//  ManagedMemory.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/23/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation
import Accelerate

let allocator: Allocator = AllocatorMalloc()

final class ManagedMemory<T>: Memory {
    typealias ElementType = T
    
    let bytes: Int
    let length: Int
    let alignment: Int
    internal let memory: UnsafeMutablePointer<T>
    
    init(from memory: ManagedMemory<T>) {
        self.length = memory.length
        self.bytes = memory.length * MemoryLayout<T>.stride
        self.alignment = MemoryLayout<T>.alignment
        
        // allocate memory
        let pointer = allocator.allocateMemory(bytes: self.bytes, alignment: self.alignment)
        
        // initialize memory
        self.memory = pointer.bindMemory(to: T.self, capacity: self.length)
        self.memory.initialize(from: memory.memory, count: self.length)
    }
    
    init(unfilledOfLength length: Int) {
        self.length = length
        self.bytes = length * MemoryLayout<T>.stride
        self.alignment = MemoryLayout<T>.alignment
        
        // allocate memory
        let pointer = allocator.allocateMemory(bytes: self.bytes, alignment: self.alignment)
        
        // initialize memory
        self.memory = pointer.bindMemory(to: T.self, capacity: length)
    }
    
    init(unfilledOfLength length: Int, withAlignment align: Int) {
        self.length = length
        self.bytes = length * MemoryLayout<T>.stride
        self.alignment = align
        
        // allocate alligned memory
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: self.bytes, alignment: self.alignment)
        
        // initialize memory
        self.memory = ptr.bindMemory(to: T.self, capacity: length)
    }
    
    deinit {
        // deinitialize memory
        memory.deinitialize(count: length)
        
        // free memory
        let pointer = UnsafeMutableRawPointer(memory)
        allocator.deallocateMemory(pointer: pointer, bytes: bytes, alignment: alignment)
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
