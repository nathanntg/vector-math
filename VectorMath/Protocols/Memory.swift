//
//  Memory.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/24/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation

protocol Memory: class {
    associatedtype ElementType
    
    var length: Int { get }
    
    // initialization
    init(unfilledOfLength length: Int)
    
    // management
    func copy() -> Self
    
    // access
    subscript(index: Int) -> ElementType { get set }
}
