//
//  Allocator.swift
//  VectorMath
//
//  Created by Nathan Perkins on 1/22/17.
//  Copyright © 2017 MaxMo Technologies LLC. All rights reserved.
//

import Foundation

internal protocol Allocator
{
    func allocateMemory(bytes: Int, alignment: Int) -> UnsafeMutableRawPointer
    func deallocateMemory(pointer: UnsafeMutableRawPointer, bytes: Int, alignment: Int)
}
