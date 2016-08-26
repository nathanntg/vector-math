//
//  CircularBufferTests.swift
//  VectorMath
//
//  Created by Nathan Perkins on 8/26/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import XCTest
import VectorMath

class CircularBufferTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreating() {
        let buffer = CircularBuffer<VectorFloat>(maxLength: 512)
        
        XCTAssertEqual(buffer.length, 0)
        XCTAssertGreaterThanOrEqual(buffer.capacity, 512)
        XCTAssertEqual(buffer.maxLength, 512)
    }
    
    func testReadingAndWriting() {
        let buffer = CircularBuffer<VectorFloat>(maxLength: 512)
        XCTAssertEqual(buffer.length, 0)
        
        // write zeros
        try! buffer.write(vector: VectorFloat(zerosOfLength: 36))
        XCTAssertEqual(buffer.length, 36)
        
        // write numbers
        try! buffer.write(vector: [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(buffer.length, 42)
        
        // read zeros
        for _ in 0..<6 {
            let read = buffer.readAndDrop(length: 6)
            XCTAssertNotNil(read)
            AssertVectorEqualWithAccuracy(read!, [0, 0, 0, 0, 0, 0])
        }
        
        // read 1...3
        let read1 = buffer.read(length: 3)
        XCTAssertNotNil(read1)
        AssertVectorEqualWithAccuracy(read1!, [1, 2, 3])
        XCTAssertEqual(buffer.length, 6)
        
        // read 1...3 again
        let read2 = buffer.read(length: 3)
        XCTAssertNotNil(read2)
        AssertVectorEqualWithAccuracy(read2!, [1, 2, 3])
        
        // drop 3
        buffer.drop(length: 3)
        XCTAssertEqual(buffer.length, 3)
        
        // read fail again
        let read3 = buffer.read(length: 4)
        XCTAssertNil(read3)
        
        // read 4...6
        let read4 = buffer.readAndDrop(length: 3)
        XCTAssertNotNil(read4)
        AssertVectorEqualWithAccuracy(read4!, [4, 5, 6])
        
        // test write fail
        do {
            try buffer.write(vector: VectorFloat(zerosOfLength: buffer.capacity + 1))
            XCTFail("able to write past end of buffer")
        }
        catch { }
    }
}
