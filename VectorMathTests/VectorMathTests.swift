//
//  VectorMathTests.swift
//  VectorMathTests
//
//  Created by Nathan Perkins on 6/23/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import XCTest
@testable import VectorMath

class VectorMathTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreation() {
        // properly allocated
        var vector = VectorFloat(zerosOfLength: 10)
        XCTAssertEqual(vector.count, 10)
        for i in 0..<10 {
            XCTAssertEqual(vector[i], 0.0)
        }
    }
    
    func testFromArray() {
        var arr = Array<Float>()
        arr += (0..<10).map(Float.init)
        
        let vector = VectorFloat(fromArray: arr)
        XCTAssertEqual(vector.count, arr.count)
        for (i, j) in vector.enumerated() {
            XCTAssertEqual(Float(i), j)
        }
        
        let vector2: VectorFloat = [2.0, 3.0, 5.0, 7.0, 11.0, 13.0]
        XCTAssertEqual(vector2.count, 6)
        XCTAssertEqual(vector2[4], 11.0)
    }
    
    func testCollection() {
        var vector = VectorFloat(zerosOfLength: 10)
        
        // asign incremental
        for i in 0..<10 {
            vector[i] = Float(i)
        }
        
        // test assignment and iteration over collection
        for (i, j) in vector.enumerated() {
            XCTAssertEqual(Float(i), j)
        }
        
        vector += 5.0
        for (i, j) in vector.enumerated() {
            XCTAssertEqual(Float(i) + 5.0, j)
        }
    }
    
    func testAddition() {
        // properly allocated
        var vector = VectorFloat(zerosOfLength: 10)
        
        // scalar addition
        vector += 1.0
        for i in 0..<10 {
            XCTAssertEqual(vector[i], 1.0)
        }
        
        // vector addition
        vector += vector
        for i in 0..<10 {
            XCTAssertEqual(vector[i], 2.0)
        }
        
        // ensure copy mechanics are working
        let vector2 = vector
        vector += 10.0
        for i in 0..<10 {
            XCTAssertEqual(vector[i], 12.0)
            XCTAssertEqual(vector2[i], 2.0)
        }
        
        // copy initializer
        var vector3 = VectorFloat(copyOf: vector2)
        vector3 += -2.0
        XCTAssertEqual(vector3.length, 10)
        for i in 0..<10 {
            XCTAssertEqual(vector3[i], 0.0)
        }
        
        // non-inplace operators
        let vector4 = vector3 + 25.0
        let vector5 = 25.0 + vector3
        let vector6 = vector4 + vector5
        for i in 0..<10 {
            XCTAssertEqual(vector3[i], 0.0)
            XCTAssertEqual(vector4[i], 25.0)
            XCTAssertEqual(vector5[i], 25.0)
            XCTAssertEqual(vector6[i], 50.0)
        }
    }
    
    func testSubtraction() {
        var vector = VectorFloat(zerosOfLength: 10)
        
        // scalar subtraction
        vector -= 5.0
        for n in vector {
            XCTAssertEqual(n, -5.0)
        }
        
        // vector subtraction
        vector -= vector
        for n in vector {
            XCTAssertEqual(n, 0.0)
        }
        
        // non-inplace scalar subtraction
        let vector2 = vector - 3.0
        XCTAssertEqual(vector2.length, vector.length)
        for (i, n) in vector2.enumerated() {
            XCTAssertEqual(vector[i], 0.0)
            XCTAssertEqual(n, -3.0)
        }
        
        // non-inplace vector subtraction
        let vector3 = vector2 - (vector + 7.0)
        XCTAssertEqual(vector3.length, vector.length)
        for (i, n) in vector3.enumerated() {
            XCTAssertEqual(vector[i], 0.0)
            XCTAssertEqual(vector2[i], -3.0)
            XCTAssertEqual(n, -10.0)
        }
    }
    
    func testPerformanceInPlace() {
        // This is an example of a performance test case.
        var vector = VectorFloat(zerosOfLength: 1000)
        self.measure {
            vector += 1.0
        }
    }
    
    func testPerformanceAllocate() {
        var vector = VectorFloat(zerosOfLength: 1000)
        self.measure {
            let vector2 = vector + 1.0
            vector = vector2 - 1.0
        }
    }
}
