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
        let vector = VectorInteger32(zerosOfLength: 10)
        AssertVector(vector, ofLength: 10, withValuesEqualTo: 0)
    }
    
    func testFromArray() {
        var arr = Array<Int32>()
        arr += 0..<10
        
        let vector = VectorInteger32(fromArray: arr)
        AssertVectorEqual(vector, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        
        // manually test just in case something is wrong with initialization, since that would affect test argument
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
        
        // test enumeration and values
        for (i, j) in vector.enumerated() {
            XCTAssertEqual(Int32(i), j)
        }
        
        vector += 5
        for (i, j) in vector.enumerated() {
            XCTAssertEqual(Int32(i) + Int32(5), j)
        }
    }
    
    func testAddition() {
        // properly allocated
        var vector = VectorInteger32(zerosOfLength: 10)
        
        // scalar addition
        vector += 1
        AssertVector(vector, ofLength: 10, withValuesEqualTo: 1)
        
        // vector addition
        vector += vector
        AssertVector(vector, ofLength: 10, withValuesEqualTo: 2)
        
        // ensure copy mechanics are working
        let vector2 = vector
        vector += 10
        AssertVector(vector, ofLength: 10, withValuesEqualTo: 12)
        AssertVector(vector2, ofLength: 10, withValuesEqualTo: 2)
        
        // copy initializer
        var vector3 = VectorInteger32(copyOf: vector2)
        vector3 += -2
        AssertVector(vector3, ofLength: 10, withValuesEqualTo: 0)
        
        // non-inplace operators
        let vector4 = vector3 + 25
        let vector5 = 25 + vector3
        let vector6 = vector4 + vector5
        AssertVector(vector3, ofLength: 10, withValuesEqualTo: 0)
        AssertVector(vector4, ofLength: 10, withValuesEqualTo: 25)
        AssertVector(vector5, ofLength: 10, withValuesEqualTo: 25)
        AssertVector(vector6, ofLength: 10, withValuesEqualTo: 50)
    }
    
    func testSubtraction() {
        var vector = VectorInteger32(zerosOfLength: 10)
        
        // scalar subtraction
        vector -= 5
        AssertVector(vector, ofLength: 10, withValuesEqualTo: -5)
        
        // vector subtraction
        vector -= vector
        AssertVector(vector, ofLength: 10, withValuesEqualTo: 0)
        
        // non-inplace scalar subtraction
        let vector2 = vector - 3
        AssertVector(vector, ofLength: 10, withValuesEqualTo: 0)
        AssertVector(vector2, ofLength: 10, withValuesEqualTo: -3)
        
        // non-inplace vector subtraction
        let vector3 = vector2 - (vector + 7)
        AssertVector(vector, ofLength: 10, withValuesEqualTo: 0)
        AssertVector(vector2, ofLength: 10, withValuesEqualTo: -3)
        AssertVector(vector3, ofLength: 10, withValuesEqualTo: -10)
        
        // non-inplace scalar vector subtraction
        let vector4 = 0 - vector3
        AssertVector(vector3, ofLength: 10, withValuesEqualTo: -10)
        AssertVector(vector4, ofLength: 10, withValuesEqualTo: 10)
    }
    
    func testMultiplication() {
        // in-place vector * scalar
        var vector: VectorInteger32 = [0, 1, 2, 3, 4, 5]
        vector *= 2
        AssertVectorEqual(vector, [0, 2, 4, 6, 8, 10])
        
        // in-place vector * vector
        vector *= vector
        AssertVectorEqual(vector, [0, 4, 16, 36, 64, 100])
        
        // non-inplace vector * scalar
        let vector3 = vector * 2
        let vector4 = 2 * vector
        AssertVectorEqual(vector, [0, 4, 16, 36, 64, 100])
        AssertVectorEqual(vector3, [0, 8, 32, 72, 128, 200])
        AssertVectorEqual(vector4, [0, 8, 32, 72, 128, 200])
        
        // non-inplace vector * vector
        let vector2: VectorInteger32 = [0, 1, 2, 3, 4, 5]
        let vector5 = vector2 * vector2
        AssertVectorEqual(vector2, [0, 1, 2, 3, 4, 5])
        AssertVectorEqual(vector5, [0, 1, 4, 9, 16, 25])
    }
    
    func testDivision() {
        // in-place vector / scalar
        var vector: VectorInteger32 = [0, 2, 4, 6, 8, 10]
        vector /= 2
        AssertVectorEqual(vector, [0, 1, 2, 3, 4, 5])
        
        // in-place vector / vector
        var vector2: VectorInteger32 = [2, 4, 6, 8, 10]
        vector2 /= vector2
        AssertVector(vector2, ofLength: 5, withValuesEqualTo: 1)
        
        // non-inplace vector / scalar
        let vector3 = vector2 / 2
        AssertVector(vector2, ofLength: 5, withValuesEqualTo: 1)
        AssertVector(vector3, ofLength: 5, withValuesEqualTo: 0)
        
        // non-inplace vector / vector
        let vector4 = vector2 / (vector3 + 1)
        AssertVector(vector4, ofLength: 5, withValuesEqualTo: 1)
        AssertVector(vector2, ofLength: 5, withValuesEqualTo: 1)
        AssertVector(vector3, ofLength: 5, withValuesEqualTo: 0)
    }
    
    func testDivisionInto() {
        // in-place scalar / vector
        var vector: VectorInteger32 = [1, 2, 3, 4, 6]
        vector.inPlaceDivideIntoScalar(12)
        AssertVectorEqual(vector, [12, 6, 4, 3, 2])
        
        // in-place vector / vector
        var vector2: VectorInteger32 = [2, 2, 2, 1, 2]
        vector2.inPlaceDivideIntoVector(vector)
        AssertVectorEqual(vector2, [6, 3, 2, 3, 1])
        
        // out-of-place vector / vector
        let vector3: VectorInteger32 = [18, 18, 18, 18, 18]
        let vector4 = vector2.divideIntoVector(vector3)
        AssertVectorEqual(vector4, [3, 6, 9, 6, 18])
        
        // out-of-place scalar / vector
        let vector5 = 36 / vector4
        AssertVectorEqual(vector4, [3, 6, 9, 6, 18])
        AssertVectorEqual(vector5, [12, 6, 4, 6, 2])
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
