//
//  ManagedMemoryTests.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/26/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import XCTest
@testable import VectorMath

class ManagedMemoryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testManagedMemory() {
        let mm = ManagedMemory<Float>(unfilledOfLength: 20)
        for i in 0..<20 {
            mm[i] = Float(i)
        }
        for i in 0..<20 {
            mm[i] += 1.0
        }
        for i in 0..<20 {
            XCTAssertGreaterThan(mm[i], Float(i))
        }
    }
    
    func testManagedMemoryCopy() {
        // initialize memory
        let mm = ManagedMemory<Float>(unfilledOfLength: 10)
        for i in 0..<10 {
            mm[i] = Float(i)
        }
        
        // copy memory
        let mm2 = mm.copy()
        for i in 0..<10 {
            XCTAssertGreaterThanOrEqual(mm2[i], Float(i))
            mm2[i] = 0
        }
        
        // ensure original memory is the same
        for i in 0..<10 {
            XCTAssertGreaterThanOrEqual(mm[i], Float(i))
            mm[i] = 0
        }
        
        // ensure new memory is correct
        for i in 0..<10 {
            XCTAssertEqual(mm2[i], 0.0)
        }
    }
    
    func testManagedMemoryAligned() {
        let mm = ManagedMemory<Float>(unfilledOfLength: 20, withAlignment: 0x4)
        for i in 0..<20 {
            mm[i] = Float(i)
        }
        for i in 0..<20 {
            mm[i] += 1.0
        }
        for i in 0..<20 {
            XCTAssertGreaterThan(mm[i], Float(i))
        }
    }
}
