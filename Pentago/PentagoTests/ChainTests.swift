//
//  ChainTests.swift
//  Pentago
//
//  Created by Itai Ferber on 5/14/16.
//  Copyright © 2016 Itai Ferber. All rights reserved.
//

import XCTest

class ChainTests: XCTestCase {
    // MARK: Chain Extension
    func testChainExtensionFromBeginning() {
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                let location = try! Location(x: x, y: y)

                let testExtension = { (start: Location, direction: Chain.Direction, exceptionCondition: () -> Bool) in
                    var chain = Chain(owner: .None, start: start, direction: direction)
                    XCTAssertConditionalThrows(exceptionCondition(), try chain.extendBeginning())
                }

                do {
                    try testExtension(location, .Right,         {x == 0})
                    try testExtension(location, .DiagonalRight, {x == 0 || y == 0})
                    try testExtension(location, .Down,          {y == 0})
                    try testExtension(location, .DiagonalLeft,  {x == 5 || y == 0})
                } catch {
                    XCTFail()
                }
            }
        }
    }

    func testChainExtensionFromEnd() {
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                let location = try! Location(x: x, y: y)

                let testExtension = { (start: Location, direction: Chain.Direction, range: Range<Int>) in
                    var chain = Chain(owner: .None, start: start, direction: direction)
                    for _ in range {
                        XCTAssertNoThrow(try chain.extendEnd())
                    }
                }

                do {
                    try testExtension(location, .Right, x ..< 5)
                    try testExtension(location, .DiagonalRight, max(x, y) ..< 5)
                    try testExtension(location, .Down, y ..< 5)
                    try testExtension(location, .DiagonalLeft, max(5 - x, y) ..< 5)
                } catch {
                    XCTFail()
                }
            }
        }
    }

    // MARK: Location Calculation
    func testChainLocations() {
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                let location = try! Location(x: x, y: y)

                let testLocations = { (start: Location, direction: Chain.Direction) in
                    var chain = Chain(owner: .None, start: start, direction: direction)
                    var locations = [location]
                    XCTAssertEqual(locations, chain.locations)

                    while let nextLocation = chain.nextLocation {
                        locations.append(nextLocation)
                        try! chain.extendEnd()
                        XCTAssertEqual(locations, chain.locations)
                    }
                }

                testLocations(location, .Right)
                testLocations(location, .DiagonalRight)
                testLocations(location, .Down)
                testLocations(location, .DiagonalLeft)
            }
        }
    }

    func testChainPreviousLocation() {
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                let location = try! Location(x: x, y: y)

                let testPrevious = { (start: Location, direction: Chain.Direction, exceptionCondition: () -> Bool, expected: () -> Location) in
                    let chain = Chain(owner: .None, start: start, direction: direction)
                    if exceptionCondition() {
                        XCTAssertNil(chain.previousLocation)
                    } else if let previousLocation = chain.previousLocation {
                        XCTAssertEqual(previousLocation, expected())
                    } else {
                        XCTFail("Chain produced unexpected nil previous location.")
                    }
                }

                testPrevious(location, .Right,         {x == 0},           {try! location.left()})
                testPrevious(location, .DiagonalRight, {x == 0 || y == 0}, {try! location.up().left()})
                testPrevious(location, .Down,          {y == 0},           {try! location.up()})
                testPrevious(location, .DiagonalLeft,  {x == 5 || y == 0}, {try! location.up().right()})
            }
        }
    }

    func testChainNextLocation() {
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                let location = try! Location(x: x, y: y)

                let testNext = { (start: Location, direction: Chain.Direction, exceptionCondition: () -> Bool, expected: () -> Location) in
                    let chain = Chain(owner: .None, start: start, direction: direction)
                    if exceptionCondition() {
                        XCTAssertNil(chain.nextLocation)
                    } else if let nextLocation = chain.nextLocation {
                        XCTAssertEqual(nextLocation, expected())
                    } else {
                        XCTFail("Chain produced unexpected nil next location.")
                    }
                }

                testNext(location, .Right,         {x == 5},           {try! location.right()})
                testNext(location, .DiagonalRight, {x == 5 || y == 5}, {try! location.down().right()})
                testNext(location, .Down,          {y == 5},           {try! location.down()})
                testNext(location, .DiagonalLeft,  {x == 0 || y == 5}, {try! location.down().left()})
            }
        }
    }
}
