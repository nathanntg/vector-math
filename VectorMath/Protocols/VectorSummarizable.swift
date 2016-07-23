//
//  VectorSummarizable.swift
//  VectorMath
//
//  Created by Nathan Perkins on 7/22/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

public protocol VectorSummarizable: Vector
{
    // SUMMARY
    
    func mean() -> Element
    func sum() -> Element
    func min() -> Element
    func max() -> Element
}
