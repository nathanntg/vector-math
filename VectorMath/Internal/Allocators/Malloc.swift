//
//  AllocatorMalloc.swift
//  VectorMath
//
//  Created by Nathan Perkins on 1/22/17.
//  Copyright © 2017 MaxMo Technologies LLC. All rights reserved.
//

import Foundation

internal final class AllocatorMalloc: Allocator
{
    func allocateMemory(bytes: Int, alignment: Int) -> UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer.allocate(bytes: bytes, alignedTo: alignment)
    }
    
    func deallocateMemory(pointer: UnsafeMutableRawPointer, bytes: Int, alignment: Int) {
        pointer.deallocate(bytes: bytes, alignedTo: alignment)
    }
}
