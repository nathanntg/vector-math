//
//  MemoryRecylcing.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/26/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation

private struct MemorySignature: Equatable, Hashable
{
    let length: Int
    let size: Int
    
    var hashValue: Int {
        return length.hashValue ^ size.hashValue
    }
    
    var totalSize: Int {
        return length * size
    }
}

private func ==(lhs: MemorySignature, rhs: MemorySignature) -> Bool {
    return lhs.length == rhs.length && lhs.size == rhs.size
}

internal class MemoryRecycling
{
    private var memoryBlocks = [MemorySignature: Array<UnsafeMutableRawPointer>]()
    private var totalMemory = 0
    private var maxMemory = 134217728 // 128MB
    
    var queue = DispatchQueue(label: "com.MaxMo.VectorMath.MemoryRecycle")
    
    func findMemory(length: Int, size: Int) -> UnsafeMutableRawPointer? {
        let sig = MemorySignature(length: length, size: size)
        return queue.sync {
            guard nil != memoryBlocks[sig] else { return nil }
            guard let ret = memoryBlocks[sig]!.popLast() else { return nil }
            
            // update total memory used
            totalMemory -= sig.totalSize
            
            return ret
        }
    }
    
    func recycleMemory(pointer ptr: UnsafeMutableRawPointer, length: Int, size: Int) {
        let sig = MemorySignature(length: length, size: size)
        queue.sync {
            // at / above threshold?
            if totalMemory >= maxMemory {
                ptr.deallocateCapacity(sig.totalSize)
                return
            }
            
            // create placeholder
            if nil == memoryBlocks[sig] {
                memoryBlocks[sig] = Array<UnsafeMutableRawPointer>()
            }
            
            // add to memory blocks
            memoryBlocks[sig]!.append(ptr)
            totalMemory += sig.totalSize
        }
    }
    
    func setMaximumMemory(_ bytes: Int) {
        queue.sync {
            maxMemory = bytes
            if totalMemory > maxMemory {
                memoryBlocks.forEach {
                    key, list in
                    
                    let totalSize = key.totalSize
                    list.forEach {
                        $0.deallocateCapacity(totalSize)
                    }
                }
                memoryBlocks.removeAll()
            }
        }
    }
}
