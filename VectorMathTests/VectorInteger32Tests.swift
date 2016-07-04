//
//  VectorInteger32Tests.swift
//  VectorMath
//
//  Created by Nathan Perkins on 7/4/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import XCTest
import VectorMath

class VectorInteger32Tests: XCTestCase {
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
        var vector = VectorInteger32(zerosOfLength: 10)
        XCTAssertEqual(vector.count, 10)
        for i in 0..<10 {
            XCTAssertEqual(vector[i], 0)
        }
    }
    
    func testFromArray() {
        var arr = Array<Int32>()
        arr += 0..<10
        
        let vector = VectorInteger32(fromArray: arr)
        XCTAssertEqual(vector.count, arr.count)
        for (i, j) in vector.enumerated() {
            XCTAssertEqual(Int32(i), j)
        }
        
        let vector2: VectorInteger32 = [2, 3, 5, 7, 11, 13]
        XCTAssertEqual(vector2.count, 6)
        XCTAssertEqual(vector2[4], 11)
    }
    
    func testSummarize() {
        var arr = Array<Int32>()
        arr += (0..<10)
        
        let vector = VectorInteger32(fromArray: arr)
        XCTAssertEqual(vector.sum(), 45)
        XCTAssertEqual(vector.mean(), 4)
        XCTAssertEqual(vector.min(), 0)
        XCTAssertEqual(vector.max(), 9)
    }
    
    func testCollection() {
        var vector = VectorInteger32(zerosOfLength: 10)
        
        // asign incremental
        for i in 0..<10 {
            vector[i] = Int32(i)
        }
        
        // test assignment and iteration over collection
        for (i, j) in vector.enumerated() {
            XCTAssertEqual(Int32(i), j)
        }
        
        vector += 5
        for (i, j) in vector.enumerated() {
            XCTAssertEqual(Int32(i) + 5, j)
        }
    }
    
    func testAddition() {
        // properly allocated
        var vector = VectorInteger32(zerosOfLength: 10)
        
        // scalar addition
        vector += 1
        for i in 0..<10 {
            XCTAssertEqual(vector[i], 1)
        }
        
        // vector addition
        vector += vector
        for i in 0..<10 {
            XCTAssertEqual(vector[i], 2)
        }
        
        // ensure copy mechanics are working
        let vector2 = vector
        vector += 10
        for i in 0..<10 {
            XCTAssertEqual(vector[i], 12)
            XCTAssertEqual(vector2[i], 2)
        }
        
        // copy initializer
        var vector3 = VectorInteger32(copyOf: vector2)
        vector3 += -2
        XCTAssertEqual(vector3.length, 10)
        for i in 0..<10 {
            XCTAssertEqual(vector3[i], 0)
        }
        
        // non-inplace operators
        let vector4 = vector3 + 25
        let vector5 = 25 + vector3
        let vector6 = vector4 + vector5
        for i in 0..<10 {
            XCTAssertEqual(vector3[i], 0)
            XCTAssertEqual(vector4[i], 25)
            XCTAssertEqual(vector5[i], 25)
            XCTAssertEqual(vector6[i], 50)
        }
    }
    
    func testSubtraction() {
        var vector = VectorInteger32(zerosOfLength: 10)
        
        // scalar subtraction
        vector -= 5
        for n in vector {
            XCTAssertEqual(n, -5)
        }
        
        // vector subtraction
        vector -= vector
        for n in vector {
            XCTAssertEqual(n, 0)
        }
        
        // non-inplace scalar subtraction
        let vector2 = vector - 3
        XCTAssertEqual(vector2.length, vector.length)
        for (i, n) in vector2.enumerated() {
            XCTAssertEqual(vector[i], 0)
            XCTAssertEqual(n, -3)
        }
        
        // non-inplace vector subtraction
        let vector3 = vector2 - (vector + 7)
        XCTAssertEqual(vector3.length, vector.length)
        for (i, n) in vector3.enumerated() {
            XCTAssertEqual(vector[i], 0)
            XCTAssertEqual(vector2[i], -3)
            XCTAssertEqual(n, -10)
        }
        
        // non-inplace scalar vector subtraction
        let vector4 = 0 - vector3
        XCTAssertEqual(vector4.length, vector.length)
        for (i, n) in vector4.enumerated() {
            XCTAssertEqual(vector3[i], -10)
            XCTAssertEqual(n, 10)
        }
    }
    
    func testMultiplication() {
        // in-place vector * scalar
        var vector: VectorInteger32 = [0, 1, 2, 3, 4, 5]
        vector *= 2
        XCTAssertEqual(vector.length, 6)
        for (i, n) in vector.enumerated() {
            XCTAssertEqual(Int32(i) * 2, n)
        }
        
        // in-place vector * vector
        vector *= vector
        XCTAssertEqual(vector.length, 6)
        for (i, n) in vector.enumerated() {
            XCTAssertEqual(Int32(i) * Int32(i) * 4, n)
        }
        
        // non-inplace vector * scalar
        let vector3 = vector * 2
        let vector4 = 2 * vector
        XCTAssertEqual(vector3.length, 6)
        XCTAssertEqual(vector4.length, 6)
        for (i, n) in vector3.enumerated() {
            XCTAssertEqual(Int32(i) * Int32(i) * 4, vector[i])
            XCTAssertEqual(Int32(i) * Int32(i) * 8, n)
            XCTAssertEqual(Int32(i) * Int32(i) * 8, vector4[i])
        }
        
        // non-inplace vector * vector
        let vector2: VectorInteger32 = [0, 1, 2, 3, 4, 5]
        let vector5 = vector2 * vector2
        XCTAssertEqual(vector5.length, 6)
        for (i, n) in vector5.enumerated() {
            XCTAssertEqual(Int32(i), vector2[i])
            XCTAssertEqual(Int32(i) * Int32(i), n)
        }
    }
    
    func testDivision() {
        // in-place vector / scalar
        var vector: VectorInteger32 = [0, 2, 4, 6, 8, 10]
        vector /= 2
        XCTAssertEqual(vector.length, 6)
        for (i, n) in vector.enumerated() {
            XCTAssertEqual(Int32(i), n)
        }
        
        // in-place vector / vector
        var vector2: VectorInteger32 = [2, 4, 6, 8, 10]
        vector2 /= vector2
        XCTAssertEqual(vector.length, 6)
        for n in vector2 {
            XCTAssertEqual(1, n)
        }
        
        // non-inplace vector / scalar
        let vector3 = vector2 / 2
        for (i, n) in vector2.enumerated() {
            XCTAssertEqual(1, n)
            XCTAssertEqual(0, vector3[i])
        }
        
        // non-inplace vector / vector
        let vector4 = vector2 / (vector3 + 1)
        for (i, n) in vector4.enumerated() {
            XCTAssertEqual(1, n)
            XCTAssertEqual(1, vector2[i])
            XCTAssertEqual(0, vector3[i])
        }
    }
    
    func testPerformanceInPlace() {
        // This is an example of a performance test case.
        var vector = VectorInteger32(zerosOfLength: 1000)
        self.measure {
            for _ in 0..<100000 {
                var vector2 = vector
                vector += 1
                vector2 += 1
            }
        }
    }
    
    func testPerformanceAllocate() {
        var vector = VectorInteger32(zerosOfLength: 1000)
        self.measure {
            for _ in 0..<100000 {
                let vector2 = vector + 1
                vector = vector2 - 1
            }
        }
    }
}
