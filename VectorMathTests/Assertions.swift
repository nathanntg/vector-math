//
//  Assertions.swift
//  VectorMath
//
//  Created by Nathan Perkins on 7/23/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import XCTest
import Foundation
@testable import VectorMath

func AssertVectorEqual<T: Vector>(_ a: T, _ b: T, file: StaticString = #file, line: UInt = #line) where T.Index == Int, T.Element: Equatable {
    guard a.length == b.length else {
        XCTFail("expected a.length == b.length", file: file, line: line)
        return
    }
    
    for i in 0..<a.length {
        XCTAssertEqual(a[i], b[i], "expected a[\(i)] == b[\(i)]", file: file, line: line)
    }
}

func AssertVectorEqualWithAccuracy<T: Vector>(_ a: T, _ b: T, accuracy: Float = 1e-6, file: StaticString = #file, line: UInt = #line) where T.Index == Int, T.Element == Float {
    guard a.length == b.length else {
        XCTFail("expected a.length == b.length", file: file, line: line)
        return
    }
    
    for i in 0..<a.length {
        XCTAssertEqualWithAccuracy(a[i], b[i], accuracy: accuracy, "expected a[\(i)] == b[\(i)]", file: file, line: line)
    }
}

func AssertVectorEqualWithAccuracy<T: Vector>(_ a: T, _ b: T, accuracy: Double = 1e-12, file: StaticString = #file, line: UInt = #line) where T.Index == Int, T.Element == Double {
    guard a.length == b.length else {
        XCTFail("expected a.length == b.length", file: file, line: line)
        return
    }
    
    for i in 0..<a.length {
        XCTAssertEqualWithAccuracy(a[i], b[i], accuracy: accuracy, "expected a[\(i)] == b[\(i)]", file: file, line: line)
    }
}

func AssertVector<T: Vector>(_ a: T, ofLength length: Int, withValuesEqualTo val: T.Element, file: StaticString = #file, line: UInt = #line) where T.Index == Int, T.Element: Equatable {
    XCTAssertEqual(a.length, length, "expected a.length == \(length)", file: file, line: line)
    
    for i in 0..<a.length {
        XCTAssertEqual(a[i], val, "expected a[\(i)] == \(val)", file: file, line: line)
    }
}

func AssertVector<T: Vector>(_ a: T, ofLength length: Int, withValuesApproximatelyEqualTo val: T.Element, withAccuracy accuracy: Float = 1e-6, file: StaticString = #file, line: UInt = #line) where T.Index == Int, T.Element == Float {
    XCTAssertEqual(a.length, length, "expected a.length == \(length)", file: file, line: line)
    
    for i in 0..<a.length {
        XCTAssertEqualWithAccuracy(a[i], val, accuracy: accuracy, "expected a[\(i)] == \(val)", file: file, line: line)
    }
}

func AssertVector<T: Vector>(_ a: T, ofLength length: Int, withValuesApproximatelyEqualTo val: T.Element, withAccuracy accuracy: Double = 1e-12, file: StaticString = #file, line: UInt = #line) where T.Index == Int, T.Element == Double {
    XCTAssertEqual(a.length, length, "expected a.length == \(length)", file: file, line: line)
    
    for i in 0..<a.length {
        XCTAssertEqualWithAccuracy(a[i], val, accuracy: accuracy, "expected a[\(i)] == \(val)", file: file, line: line)
    }
}

