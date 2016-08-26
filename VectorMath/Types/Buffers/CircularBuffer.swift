//
//  CircularBuffer.swift
//  VectorMath
//
//  Created by Nathan Perkins on 8/26/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation

public enum CircularBufferError: Error
{
    case InsufficientCapacity
}

public class CircularBuffer<T: VectorMemory> where T.Index == Int
{
    public typealias VectorType = T
    public typealias ElementType = T.Element
    public typealias IndexType = T.Index
    
    private var memory: CircularMemory<ElementType>
    
    public var capacity: Int {
        get {
            return memory.capacity
        }
    }
    
    public var length: Int {
        get {
            return memory.length
        }
    }
    
    public var maxLength: Int {
        get {
            return memory.maxLength
        }
    }
    
    public init(maxLength: Int) {
        memory = CircularMemory<ElementType>(maxLength: maxLength)
    }
    
    public func write(vector: VectorType) throws {
        do {
            try memory.produce(data: vector.unsafePointer)
        }
        catch {
            throw CircularBufferError.InsufficientCapacity
        }
    }
    
    public func read(length: IndexType) -> VectorType? {
        // check that there is any data to read
        guard let tail = memory.tail() else {
            return nil
        }
        
        // check that there is enough data to read
        guard tail.count >= length else {
            return nil
        }
        
        // return vector
        let pointer = tail.baseAddress!
        return VectorType(copyFromPointer: pointer, ofLength: length)
    }
    
    public func drop(length: Int) {
        memory.consume(count: length)
    }
    
    public func readAndDrop(length: IndexType) -> VectorType? {
        if let vector = read(length: length) {
            drop(length: length)
            return vector
        }
        
        return nil
    }
    
    public func empty() {
        memory.clear()
    }
}
