//
//  BaseTests.swift
//  Pentago
//
//  Created by Itai Ferber on 5/14/16.
//  Copyright © 2016 Itai Ferber. All rights reserved.
//

import XCTest

class BaseTests: XCTestCase {
    // MARK: Testing Location Initialization
    func testLocationInitialization() {
        for y in -10 ... 10 {
            for x in -10 ... 10 {
                XCTAssertConditionalThrows(x < 0 || x >= 6 || y < 0 || y >= 6, try Location(x: x, y: y))
            }
        }
    }

    // MARK: Testing Relative Locations
    func testLocationRelativeDirectionCardinals() {
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                XCTAssertConditionalThrows(y == 0, try Location(x: x, y: y).up())
                XCTAssertConditionalThrows(y == 5, try Location(x: x, y: y).down())
                XCTAssertConditionalThrows(x == 0, try Location(x: x, y: y).left())
                XCTAssertConditionalThrows(x == 5, try Location(x: x, y: y).right())
            }
        }
    }
}
