//
//  CircularBuffer.swift
//  VectorMath
//
//  Created by Nathan Perkins on 8/24/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation
import TPCircularBuffer

enum CircularMemoryError: Error {
    case InsufficientCapacity
}

final class CircularMemory<T>
{
    internal var buffer: TPCircularBuffer
    
    let maxLength: Int
    
    var capacity: Int {
        get {
            // get buffer write point and available bytes
            var availableBytes: Int32 = 0
            TPCircularBufferHead(&buffer, &availableBytes)
            
            return Int(availableBytes)
        }
    }
    
    var length: Int {
        get {
            // get buffer read point and available bytes
            var availableBytes: Int32 = 0
            TPCircularBufferTail(&buffer, &availableBytes)
            
            return Int(availableBytes)
        }
    }
    
    init(maxLength: Int) {
        // store max length
        self.maxLength = maxLength
        
        // length in bytes
        let maxBytes = MemoryLayout<T>.size * maxLength
        
        // create buffer
        buffer = TPCircularBuffer()
        if !TPCircularBufferInit(&buffer, Int32(maxBytes)) {
            fatalError("Unable to allocate circular buffer.")
        }
    }
    
    deinit {
        // clean up
        TPCircularBufferCleanup(&buffer)
    }
    
    private func countToBytes(count: Int) -> Int {
        return count * MemoryLayout<T>.size
    }
    
    private func bytesToCount(bytes: Int) -> Int {
        return bytes / MemoryLayout<T>.size
    }
    
    /// Buffer for reading data from the tail of the circular buffer. Returns nil if there is no data.
    func tail() -> UnsafeBufferPointer<T>? {
        // get buffer read point and available bytes
        var availableBytes: Int32 = 0
        guard let tail = TPCircularBufferTail(&buffer, &availableBytes) else {
            return nil
        }
        
        // get count
        let count = bytesToCount(bytes: Int(availableBytes))
        
        // return buffer pointer
        return UnsafeBufferPointer(start: tail.bindMemory(to: T.self, capacity: count), count: count)
    }
    
    /// Bufer for writing new data at the head of the circular buffer. Returns nil if there is no capacity.
    func head() -> UnsafeMutableBufferPointer<T>? {
        // get buffer write point and available bytes
        var availableBytes: Int32 = 0
        guard let head = TPCircularBufferHead(&buffer, &availableBytes) else {
            return nil
        }
        
        // get count
        let count = bytesToCount(bytes: Int(availableBytes))
        
        // return buffer pointer
        return UnsafeMutableBufferPointer(start: head.bindMemory(to: T.self, capacity: count), count: count)
    }
    
    func consume(count: Int) {
        // convert count to bytes
        let bytes = countToBytes(count: count)
        
        // consume
        TPCircularBufferConsume(&buffer, Int32(bytes))
    }
    
    func produce(data: UnsafeBufferPointer<T>) throws {
        // has based address? otherwise means there is no data
        if let baseAddress = data.baseAddress {
            // calculate number of bytes
            let bytes = data.count * MemoryLayout<T>.size
            
            // produce bytes
            if !TPCircularBufferProduceBytes(&buffer, baseAddress, Int32(bytes)) {
                throw CircularMemoryError.InsufficientCapacity
            }
        }
    }
    
    func produce(data: ManagedMemory<T>) throws {
        // calculate number of bytes
        let bytes = data.length * MemoryLayout<T>.size
        
        // produce bytes
        if !TPCircularBufferProduceBytes(&buffer, data.memory, Int32(bytes)) {
            throw CircularMemoryError.InsufficientCapacity
        }
    }
    
    func produce(count: Int) {
        // convert count to bytes
        let bytes = countToBytes(count: count)
        
        // produce
        TPCircularBufferProduce(&buffer, Int32(bytes))
    }
    
    func clear() {
        TPCircularBufferClear(&buffer)
    }
}
