//
//  SimpleSegregatedStorage.swift
//  VectorMath
//
//  Created by Nathan Perkins on 1/22/17.
//  Copyright © 2017 MaxMo Technologies LLC. All rights reserved.
//

import Foundation

let kDefaultPageAlignment = 8

fileprivate struct Chunk
{
    var next: UnsafeMutablePointer<Chunk>?
}

fileprivate class AllocatorPage
{
    var chunkBytes: Int
    var chunkCount: Int = 0
    var pageBytes: Int = 0
    
    var firstFree: UnsafeMutablePointer<Chunk>?
    
    init(chunkBytes: Int, chunkCount: Int=0) {
        // chunk bytes
        self.chunkBytes = chunkBytes
        
        // extend
        if chunkCount > 0 {
            extendBy(additionalChunks: chunkCount)
        }
    }
    
    init(chunkBytes: Int, pageBytes: Int) {
        // chunk bytes
        self.chunkBytes = chunkBytes
        
        // extend
        if pageBytes > 0 {
            extendBy(additionalBytes: pageBytes)
        }
    }
    
    func extendBy(additionalBytes: Int) {
        extendBy(additionalChunks: additionalBytes / (chunkBytes + MemoryLayout<Chunk>.stride))
    }
    
    // NOT THREAD SAFE AT ALL
    func extendBy(additionalChunks: Int) {
        print("\(additionalChunks) x \(chunkBytes)")
        
        // must be positive number of chunks
        guard additionalChunks > 0 else { return }
        
        let alignment = max(MemoryLayout<Chunk>.alignment, kDefaultPageAlignment)
        let stride = chunkBytes + MemoryLayout<Chunk>.stride
        let newBytes = additionalChunks * stride
        let newMemory = UnsafeMutableRawPointer.allocate(bytes: newBytes, alignedTo: alignment)
        
        var first: UnsafeMutablePointer<Chunk>?
        var last: UnsafeMutablePointer<Chunk>?
        
        for i in 0..<additionalChunks {
            // get chunk
            let chunk = newMemory.advanced(by: i * stride).bindMemory(to: Chunk.self, capacity: 1)
            
            // initialize chunk
            chunk.initialize(to: Chunk(next: last))
            
            // keep track of the first and last chunk
            if i == 0 {
                first = chunk
            }
            last = chunk
        }
        
        // insert
        first?.pointee.next = firstFree
        firstFree = last
    }
    
    func allocate() -> UnsafeMutableRawPointer? {
        guard let free = firstFree else { return nil }
        
        // memory to return
        let memory = UnsafeMutableRawPointer(free).advanced(by: MemoryLayout<Chunk>.stride)
        
        // update first free
        firstFree = free.pointee.next
        
        return memory
    }
    
    func allocateOrExtend() -> UnsafeMutableRawPointer {
        
        // use existing
        if let memory = allocate() {
            return memory
        }
        
        // try extending
        extendBy(additionalChunks: 16)
        
        return allocate()!
    }
    
    func free(memory: UnsafeMutableRawPointer) {
        // find memory header
        let chunk = memory.advanced(by: 0 - MemoryLayout<Chunk>.stride).assumingMemoryBound(to: Chunk.self)
        
        // insert into first free list
        let lastFree = firstFree
        firstFree = chunk
        firstFree?.pointee.next = lastFree
    }
}

internal final class AllocatorSimpleSegregatedStorage: Allocator
{
    private let pages1K = AllocatorPage(chunkBytes: 1_024)
    private let pages4K = AllocatorPage(chunkBytes: 4_096)
    private let pages32K = AllocatorPage(chunkBytes: 32_768)
    
    private func getPage(bytes: Int) -> AllocatorPage? {
        if bytes <= 1_024 {
            return pages1K
        }
        if bytes <= 4_096 {
            return pages4K
        }
        if bytes <= 32_768 {
            return pages32K
        }
        return nil
    }
    
    func allocateMemory(bytes: Int, alignment: Int) -> UnsafeMutableRawPointer {
        guard let page = getPage(bytes: bytes) else { fatalError("Unsupported memory size.") }
        return page.allocateOrExtend()
    }
    
    func deallocateMemory(pointer: UnsafeMutableRawPointer, bytes: Int, alignment: Int) {
        guard let page = getPage(bytes: bytes) else { fatalError("Unsupported memory size.") }
        page.free(memory: pointer)
    }
}

