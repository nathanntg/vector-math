//
//  ComplexDouble.swift
//  VectorMath
//
//  Created by Nathan Perkins on 7/22/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation
import Accelerate

public typealias ComplexDouble = DSPDoubleComplex

extension ComplexDouble: CustomStringConvertible {
    public var description: String {
        return "\(real) + \(imag) i"
    }
}
