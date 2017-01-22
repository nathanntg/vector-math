//
//  ManagedMemory.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/23/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation
import Accelerate

let recycle: MemoryRecycling? = nil

private func allocateMemory<T>(withLength length: Int) -> UnsafeMutablePointer<T> {
    if let r = recycle {
        if let ptr = r.findMemory(length: length, size: MemoryLayout<T>.size) {
            return UnsafeMutablePointer<T>(ptr)
        }
    }
    
    return UnsafeMutablePointer<T>.allocate(capacity: length)
}

private func freeMemory<T>(atPointer ptr: UnsafeMutablePointer<T>, withLength length: Int) {
    ptr.deinitialize(count: length)
    if let r = recycle {
        r.recycleMemory(pointer: UnsafeMutableRawPointer(ptr), length: length, size: MemoryLayout<T>.size)
    }
    else {
        ptr.deallocate(capacity: length)
    }
}

final class ManagedMemory<T>: Memory {
    typealias ElementType = T
    
    let length: Int
    internal let memory: UnsafeMutablePointer<T>
    
    init(from memory: ManagedMemory<T>) {
        self.length = memory.length
        self.memory = allocateMemory(withLength: length)
        self.memory.initialize(from: memory.memory, count: length)
    }
    
    init(unfilledOfLength length: Int) {
        self.length = length
        self.memory = allocateMemory(withLength: length)
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
        freeMemory(atPointer: memory, withLength: length)
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
