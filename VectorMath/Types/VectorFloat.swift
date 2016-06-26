//
//  VectorFloat.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/24/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation

struct VectorFloat: Vector
{
    typealias Index = Int
    typealias ElementType = Float
    
    private var memory: ManagedMemory<Float>
    
    // TODO: INVESTIGATE if there is a performance penalty for this, or if it just gets inlined
    var count: Int {
        get {
            return memory.length
        }
    }
    var length: Int {
        get {
            return memory.length
        }
    }
    
    mutating private func ensureUnique() {
        if !isUniquelyReferencedNonObjC(&memory) {
            memory = memory.copy()
        }
    }
}
