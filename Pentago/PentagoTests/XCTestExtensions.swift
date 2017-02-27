//
//  XCTestExtensions.swift
//  Pentago
//
//  Created by Itai Ferber on 5/14/16.
//  Copyright © 2016 Itai Ferber. All rights reserved.
//

import XCTest

func XCTAssertThrows<T>(@autoclosure expression: () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    do {
        try expression()
        XCTFail("No error to catch! - \(message)", file: file, line: line)
    } catch {
    }
}

func XCTAssertNoThrow<T>(@autoclosure expression: () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    do {
        try expression()
    } catch let error {
        XCTFail("Caught error: \(error) - \(message)", file: file, line: line)
    }
}

func XCTAssertConditionalThrows<T>(@autoclosure condition: () -> Bool, @autoclosure _ expression: () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    if condition() {
        XCTAssertThrows(expression, message, file: file, line: line)
    } else {
        XCTAssertNoThrow(expression, message, file: file, line: line)
    }
}
