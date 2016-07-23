//
//  VectorDoubleTests.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/26/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import XCTest
import VectorMath

class VectorDoubleTests: XCTestCase {

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
        let vector = VectorDouble(zerosOfLength: 10)
        AssertVector(vector, ofLength: 10, withValuesApproximatelyEqualTo: 0)
    }
    
    func testFromArray() {
        var arr = Array<Double>()
        arr += (0..<10).map(Double.init)
        
        let vector = VectorDouble(fromArray: arr)
        AssertVectorEqualWithAccuracy(vector, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        
        // manually test just in case something is wrong with initialization, since that would affect test argument
        let vector2: VectorDouble = [2.0, 3.0, 5.0, 7.0, 11.0, 13.0]
        XCTAssertEqual(vector2.count, 6)
        XCTAssertEqualWithAccuracy(vector2[4], 11.0, accuracy: 1e-7)
    }
    
    func testSummarize() {
        var arr = Array<Double>()
        arr += (0..<10).map(Double.init)
        
        let vector = VectorDouble(fromArray: arr)
        XCTAssertEqualWithAccuracy(vector.sum(), 45.0, accuracy: 1e-7)
        XCTAssertEqualWithAccuracy(vector.mean(), 4.5, accuracy: 1e-7)
        XCTAssertEqualWithAccuracy(vector.min(), 0.0, accuracy: 1e-7)
        XCTAssertEqualWithAccuracy(vector.max(), 9.0, accuracy: 1e-7)
    }
    
    func testCollection() {
        var vector = VectorDouble(zerosOfLength: 10)
        
        // asign incremental
        for i in 0..<10 {
            vector[i] = Double(i)
        }
        
        // test enumeration and values
        for (i, j) in vector.enumerated() {
            XCTAssertEqualWithAccuracy(Double(i), j, accuracy: 1e-7)
        }
        
        vector += 5.0
        for (i, j) in vector.enumerated() {
            XCTAssertEqualWithAccuracy(Double(i) + 5.0, j, accuracy: 1e-7)
        }
    }
    
    func testAddition() {
        // properly allocated
        var vector = VectorDouble(zerosOfLength: 10)
        
        // scalar addition
        vector += 1.0
        AssertVector(vector, ofLength: 10, withValuesApproximatelyEqualTo: 1)
        
        // vector addition
        vector += vector
        AssertVector(vector, ofLength: 10, withValuesApproximatelyEqualTo: 2)
        
        // ensure copy mechanics are working
        let vector2 = vector
        vector += 10.0
        AssertVector(vector, ofLength: 10, withValuesApproximatelyEqualTo: 12)
        AssertVector(vector2, ofLength: 10, withValuesApproximatelyEqualTo: 2)
        
        // copy initializer
        var vector3 = VectorDouble(copyOf: vector2)
        vector3 += -2.0
        AssertVector(vector3, ofLength: 10, withValuesApproximatelyEqualTo: 0)
        
        // non-inplace operators
        let vector4 = vector3 + 25.0
        let vector5 = 25.0 + vector3
        let vector6 = vector4 + vector5
        AssertVector(vector3, ofLength: 10, withValuesApproximatelyEqualTo: 0)
        AssertVector(vector4, ofLength: 10, withValuesApproximatelyEqualTo: 25)
        AssertVector(vector5, ofLength: 10, withValuesApproximatelyEqualTo: 25)
        AssertVector(vector6, ofLength: 10, withValuesApproximatelyEqualTo: 50)
    }
    
    func testSubtraction() {
        var vector = VectorDouble(zerosOfLength: 10)
        
        // scalar subtraction
        vector -= 5.0
        AssertVector(vector, ofLength: 10, withValuesApproximatelyEqualTo: -5)
        
        // vector subtraction
        vector -= vector
        AssertVector(vector, ofLength: 10, withValuesApproximatelyEqualTo: 0)
        
        // non-inplace scalar subtraction
        let vector2 = vector - 3.0
        AssertVector(vector, ofLength: 10, withValuesApproximatelyEqualTo: 0)
        AssertVector(vector2, ofLength: 10, withValuesApproximatelyEqualTo: -3)
        
        // non-inplace vector subtraction
        let vector3 = vector2 - (vector + 7.0)
        AssertVector(vector, ofLength: 10, withValuesApproximatelyEqualTo: 0)
        AssertVector(vector2, ofLength: 10, withValuesApproximatelyEqualTo: -3)
        AssertVector(vector3, ofLength: 10, withValuesApproximatelyEqualTo: -10)
        
        // non-inplace scalar vector subtraction
        let vector4 = 0.0 - vector3
        AssertVector(vector3, ofLength: 10, withValuesApproximatelyEqualTo: -10)
        AssertVector(vector4, ofLength: 10, withValuesApproximatelyEqualTo: 10)
    }
    
    func testMultiplication() {
        // in-place vector * scalar
        var vector: VectorDouble = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]
        vector *= 2.0
        AssertVectorEqualWithAccuracy(vector, [0, 2, 4, 6, 8, 10])
        
        // in-place vector * vector
        vector *= vector
        AssertVectorEqualWithAccuracy(vector, [0, 4, 16, 36, 64, 100])
        
        // non-inplace vector * scalar
        let vector3 = vector * 2.0
        let vector4 = 2.0 * vector
        AssertVectorEqualWithAccuracy(vector, [0, 4, 16, 36, 64, 100])
        AssertVectorEqualWithAccuracy(vector3, [0, 8, 32, 72, 128, 200])
        AssertVectorEqualWithAccuracy(vector4, [0, 8, 32, 72, 128, 200])
        
        // non-inplace vector * vector
        let vector2: VectorDouble = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]
        let vector5 = vector2 * vector2
        AssertVectorEqualWithAccuracy(vector2, [0, 1, 2, 3, 4, 5])
        AssertVectorEqualWithAccuracy(vector5, [0, 1, 4, 9, 16, 25])
    }
    
    func testDivision() {
        // in-place vector / scalar
        var vector: VectorDouble = [0.0, 2.0, 4.0, 6.0, 8.0, 10.0]
        vector /= 2.0
        AssertVectorEqualWithAccuracy(vector, [0, 1, 2, 3, 4, 5])
        
        // in-place vector / vector
        var vector2: VectorDouble = [2.0, 4.0, 6.0, 8.0, 10.0]
        vector2 /= vector2
        AssertVector(vector2, ofLength: 5, withValuesApproximatelyEqualTo: 1)
        
        // non-inplace vector / scalar
        let vector3 = vector2 / 2.0
        AssertVector(vector2, ofLength: 5, withValuesApproximatelyEqualTo: 1)
        AssertVector(vector3, ofLength: 5, withValuesApproximatelyEqualTo: 0.5)
        
        // non-inplace vector / vector
        let vector4 = vector2 / vector3
        AssertVector(vector4, ofLength: 5, withValuesApproximatelyEqualTo: 2)
        AssertVector(vector2, ofLength: 5, withValuesApproximatelyEqualTo: 1)
        AssertVector(vector3, ofLength: 5, withValuesApproximatelyEqualTo: 0.5)
        
        // infinity
        var vector5: VectorDouble = [0, 0, 0]
        vector5 /= 0
        XCTAssert(vector5[0].isNaN, "isNaN")
        
        // nan
        var vector6: VectorDouble = [1, 1, 1]
        vector6 /= 0
        XCTAssert(vector6[0].isInfinite, "isInfinite")
    }
    
    func testDivisionInto() {
        // in-place scalar / vector
        var vector: VectorDouble = [1.0, 2.0, 4.0, 5.0]
        vector.inPlaceDivideIntoScalar(1)
        AssertVectorEqualWithAccuracy(vector, [1, 0.5, 0.25, 0.2])
        
        // in-place vector / vector
        var vector2: VectorDouble = [1, 0.1, 0.01, 0.001]
        vector2.inPlaceDivideIntoVector(vector)
        AssertVectorEqualWithAccuracy(vector2, [1, 5, 25, 200])
        
        // out-of-place vector / vector
        let vector3: VectorDouble = [1000, 1000, 1000, 1000]
        let vector4 = vector2.divideIntoVector(vector3)
        AssertVectorEqualWithAccuracy(vector4, [1000, 200, 40, 5])
        
        // out-of-place scalar / vector
        let vector5 = 1 / vector3
        AssertVectorEqualWithAccuracy(vector3, [1000, 1000, 1000, 1000])
        AssertVectorEqualWithAccuracy(vector5, [0.001, 0.001, 0.001, 0.001])
        
        // infinity
        var vector6: VectorDouble = [0, 0, 0, 0]
        vector6.inPlaceDivideIntoScalar(1)
        XCTAssert(vector6[0].isInfinite, "isInfinite")
        
        // nan
        var vector7: VectorDouble = [0, 0, 0, 0]
        vector7.inPlaceDivideIntoScalar(0)
        XCTAssert(vector7[0].isNaN, "isNaN")
    }
    
    func testPerformanceInPlace() {
        // This is an example of a performance test case.
        var vector = VectorDouble(zerosOfLength: 1000)
        self.measure {
            for _ in 0..<100000 {
                var vector2 = vector
                vector += 1.0
                vector2 += 1.0
            }
        }
    }
    
    func testPerformanceAllocate() {
        var vector = VectorDouble(zerosOfLength: 1000)
        self.measure {
            for _ in 0..<100000 {
                let vector2 = vector + 1.0
                vector = vector2 - 1.0
            }
        }
    }
}
