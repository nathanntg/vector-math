//
//  Vector.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/24/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation

protocol Vector
{
    associatedtype ElementType
    
    var count: Int { get }
    var length: Int { get }
}
