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
    
    func testAddition() {
        // properly allocated
        var vector = VectorFloat(zerosOfLength: 10)
        for i in 0..<10 {
            XCTAssertEqual(vector[i], 0.0)
        }
        
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
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
