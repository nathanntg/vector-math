//
//  VectorFloatTests.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/26/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import XCTest
import VectorMath

class VectorFloatTests: XCTestCase {
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
            XCTAssertEqualWithAccuracy(vector[i], 0.0, accuracy: 1e-7)
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
        XCTAssertEqualWithAccuracy(vector2[4], 11.0, accuracy: 1e-7)
    }
    
    func testSummarize() {
        var arr = Array<Float>()
        arr += (0..<10).map(Float.init)
        
        let vector = VectorFloat(fromArray: arr)
        XCTAssertEqualWithAccuracy(vector.sum(), 45.0, accuracy: 1e-7)
        XCTAssertEqualWithAccuracy(vector.mean(), 4.5, accuracy: 1e-7)
        XCTAssertEqualWithAccuracy(vector.min(), 0.0, accuracy: 1e-7)
        XCTAssertEqualWithAccuracy(vector.max(), 9.0, accuracy: 1e-7)
    }
    
    func testCollection() {
        var vector = VectorFloat(zerosOfLength: 10)
        
        // asign incremental
        for i in 0..<10 {
            vector[i] = Float(i)
        }
        
        // test assignment and iteration over collection
        for (i, j) in vector.enumerated() {
            XCTAssertEqualWithAccuracy(Float(i), j, accuracy: 1e-7)
        }
        
        vector += 5.0
        for (i, j) in vector.enumerated() {
            XCTAssertEqualWithAccuracy(Float(i) + 5.0, j, accuracy: 1e-7)
        }
    }
    
    func testAddition() {
        // properly allocated
        var vector = VectorFloat(zerosOfLength: 10)
        
        // scalar addition
        vector += 1.0
        for i in 0..<10 {
            XCTAssertEqualWithAccuracy(vector[i], 1.0, accuracy: 1e-7)
        }
        
        // vector addition
        vector += vector
        for i in 0..<10 {
            XCTAssertEqualWithAccuracy(vector[i], 2.0, accuracy: 1e-7)
        }
        
        // ensure copy mechanics are working
        let vector2 = vector
        vector += 10.0
        for i in 0..<10 {
            XCTAssertEqualWithAccuracy(vector[i], 12.0, accuracy: 1e-7)
            XCTAssertEqualWithAccuracy(vector2[i], 2.0, accuracy: 1e-7)
        }
        
        // copy initializer
        var vector3 = VectorFloat(copyOf: vector2)
        vector3 += -2.0
        XCTAssertEqual(vector3.length, 10)
        for i in 0..<10 {
            XCTAssertEqualWithAccuracy(vector3[i], 0.0, accuracy: 1e-7)
        }
        
        // non-inplace operators
        let vector4 = vector3 + 25.0
        let vector5 = 25.0 + vector3
        let vector6 = vector4 + vector5
        for i in 0..<10 {
            XCTAssertEqualWithAccuracy(vector3[i], 0.0, accuracy: 1e-7)
            XCTAssertEqualWithAccuracy(vector4[i], 25.0, accuracy: 1e-7)
            XCTAssertEqualWithAccuracy(vector5[i], 25.0, accuracy: 1e-7)
            XCTAssertEqualWithAccuracy(vector6[i], 50.0, accuracy: 1e-7)
        }
    }
    
    func testSubtraction() {
        var vector = VectorFloat(zerosOfLength: 10)
        
        // scalar subtraction
        vector -= 5.0
        for n in vector {
            XCTAssertEqualWithAccuracy(n, -5.0, accuracy: 1e-7)
        }
        
        // vector subtraction
        vector -= vector
        for n in vector {
            XCTAssertEqualWithAccuracy(n, 0.0, accuracy: 1e-7)
        }
        
        // non-inplace scalar subtraction
        let vector2 = vector - 3.0
        XCTAssertEqual(vector2.length, vector.length)
        for (i, n) in vector2.enumerated() {
            XCTAssertEqualWithAccuracy(vector[i], 0.0, accuracy: 1e-7)
            XCTAssertEqualWithAccuracy(n, -3.0, accuracy: 1e-7)
        }
        
        // non-inplace vector subtraction
        let vector3 = vector2 - (vector + 7.0)
        XCTAssertEqual(vector3.length, vector.length)
        for (i, n) in vector3.enumerated() {
            XCTAssertEqualWithAccuracy(vector[i], 0.0, accuracy: 1e-7)
            XCTAssertEqualWithAccuracy(vector2[i], -3.0, accuracy: 1e-7)
            XCTAssertEqualWithAccuracy(n, -10.0, accuracy: 1e-7)
        }
        
        // non-inplace scalar vector subtraction
        let vector4 = 0.0 - vector3
        XCTAssertEqual(vector4.length, vector.length)
        for (i, n) in vector4.enumerated() {
            XCTAssertEqualWithAccuracy(vector3[i], -10.0, accuracy: 1e-7)
            XCTAssertEqualWithAccuracy(n, 10.0, accuracy: 1e-7)
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
