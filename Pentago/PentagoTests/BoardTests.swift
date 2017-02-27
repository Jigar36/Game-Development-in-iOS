//
//  BoardTests.swift
//  Pentago
//
//  Created by Itai Ferber on 5/13/16.
//  Copyright © 2016 Itai Ferber. All rights reserved.
//

import XCTest

class BoardTests: XCTestCase {
    // MARK: Playing Marbles
    func testValidPlayMarble() {
        var board1 = Board()
        var board2 = Board()
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                let location = try! Location(x: x, y: y)
                XCTAssertNoThrow(try board1.playMarble(.Player1, atLocation:location))
                XCTAssertNoThrow(try board2.playMarble(.Player2, atLocation:location))
            }
        }
    }

    func testPlayMarbleWithInvalidPlayer() {
        var board = Board()
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                let location = try! Location(x: x, y: y)
                XCTAssertThrows(try board.playMarble(.None, atLocation: location))
            }
        }
    }

    func testPlayMarbleInOccupiedLocation() {
        var board1 = Board()
        var board2 = Board()
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                let location = try! Location(x: x, y: y)
                XCTAssertNoThrow(try board1.playMarble(.Player1, atLocation: location))
                XCTAssertThrows(try board1.playMarble(.Player2, atLocation: location))

                XCTAssertNoThrow(try board2.playMarble(.Player2, atLocation: location))
                XCTAssertThrows(try board2.playMarble(.Player1, atLocation: location))
            }
        }
    }

    // MARK: Rotating Quadrants
    func testTopLeftQuadrantRotation() {
        var board = Board()
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                let player: Owner
                if y % 2 == 0 {
                    player = .Player1
                } else {
                    player = .Player2
                }

                XCTAssertNoThrow(try board.playMarble(player, atLocation: try! Location(x: x, y: y)))
            }
        }

        // The reference board is the same board, with the equivalent quadrant
        // manually rotated.
        var referenceBoard = board
        referenceBoard[try! Location(x: 0, y: 0)] = .Player1
        referenceBoard[try! Location(x: 1, y: 0)] = .Player2
        referenceBoard[try! Location(x: 2, y: 0)] = .Player1
        referenceBoard[try! Location(x: 0, y: 1)] = .Player1
        referenceBoard[try! Location(x: 2, y: 1)] = .Player1
        referenceBoard[try! Location(x: 0, y: 2)] = .Player1
        referenceBoard[try! Location(x: 1, y: 2)] = .Player2
        referenceBoard[try! Location(x: 2, y: 2)] = .Player1

        // We're going to rotate a copy of the board so we can compare to the
        // original
        var copy = board

        for i in 0 ..< 4 {
            let _ = copy.rotateQuadrant(.TopLeft, inDirection: .Clockwise)
            if i % 2 == 0 {
                XCTAssertEqual(copy, referenceBoard)
            } else {
                XCTAssertEqual(copy, board)
            }
        }

        for i in 0 ..< 4 {
            let _ = copy.rotateQuadrant(.TopLeft, inDirection: .CounterClockwise)
            if i % 2 == 0 {
                XCTAssertEqual(copy, referenceBoard)
            } else {
                XCTAssertEqual(copy, board)
            }
        }
    }

    func testTopRightQuadrantRotation() {
        var board = Board()
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                let player: Owner
                if y % 2 == 0 {
                    player = .Player1
                } else {
                    player = .Player2
                }

                XCTAssertNoThrow(try board.playMarble(player, atLocation: try! Location(x: x, y: y)))
            }
        }

        // The reference board is the same board, with the equivalent quadrant
        // manually rotated.
        var referenceBoard = board
        referenceBoard[try! Location(x: 3, y: 0)] = .Player1
        referenceBoard[try! Location(x: 4, y: 0)] = .Player2
        referenceBoard[try! Location(x: 5, y: 0)] = .Player1
        referenceBoard[try! Location(x: 3, y: 1)] = .Player1
        referenceBoard[try! Location(x: 5, y: 1)] = .Player1
        referenceBoard[try! Location(x: 3, y: 2)] = .Player1
        referenceBoard[try! Location(x: 4, y: 2)] = .Player2
        referenceBoard[try! Location(x: 5, y: 2)] = .Player1

        // We're going to rotate a copy of the board so we can compare to the
        // original
        var copy = board

        for i in 0 ..< 4 {
            let _ = copy.rotateQuadrant(.TopRight, inDirection: .Clockwise)
            if i % 2 == 0 {
                XCTAssertEqual(copy, referenceBoard)
            } else {
                XCTAssertEqual(copy, board)
            }
        }

        for i in 0 ..< 4 {
            let _ = copy.rotateQuadrant(.TopRight, inDirection: .CounterClockwise)
            if i % 2 == 0 {
                XCTAssertEqual(copy, referenceBoard)
            } else {
                XCTAssertEqual(copy, board)
            }
        }
    }

    func testBottomLeftQuadrantRotation() {
        var board = Board()
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                let player: Owner
                if y % 2 == 0 {
                    player = .Player1
                } else {
                    player = .Player2
                }

                XCTAssertNoThrow(try board.playMarble(player, atLocation: try! Location(x: x, y: y)))
            }
        }

        // The reference board is the same board, with the equivalent quadrant
        // manually rotated.
        var referenceBoard = board
        referenceBoard[try! Location(x: 0, y: 3)] = .Player2
        referenceBoard[try! Location(x: 1, y: 3)] = .Player1
        referenceBoard[try! Location(x: 2, y: 3)] = .Player2
        referenceBoard[try! Location(x: 0, y: 4)] = .Player2
        referenceBoard[try! Location(x: 2, y: 4)] = .Player2
        referenceBoard[try! Location(x: 0, y: 5)] = .Player2
        referenceBoard[try! Location(x: 1, y: 5)] = .Player1
        referenceBoard[try! Location(x: 2, y: 5)] = .Player2

        // We're going to rotate a copy of the board so we can compare to the
        // original
        var copy = board

        for i in 0 ..< 4 {
            let _ = copy.rotateQuadrant(.BottomLeft, inDirection: .Clockwise)
            if i % 2 == 0 {
                XCTAssertEqual(copy, referenceBoard)
            } else {
                XCTAssertEqual(copy, board)
            }
        }

        for i in 0 ..< 4 {
            let _ = copy.rotateQuadrant(.BottomLeft, inDirection: .CounterClockwise)
            if i % 2 == 0 {
                XCTAssertEqual(copy, referenceBoard)
            } else {
                XCTAssertEqual(copy, board)
            }
        }
    }

    func testBottomRightQuadrantRotation() {
        var board = Board()
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                let player: Owner
                if y % 2 == 0 {
                    player = .Player1
                } else {
                    player = .Player2
                }

                XCTAssertNoThrow(try board.playMarble(player, atLocation: try! Location(x: x, y: y)))
            }
        }

        // The reference board is the same board, with the equivalent quadrant
        // manually rotated.
        var referenceBoard = board
        referenceBoard[try! Location(x: 3, y: 3)] = .Player2
        referenceBoard[try! Location(x: 4, y: 3)] = .Player1
        referenceBoard[try! Location(x: 5, y: 3)] = .Player2
        referenceBoard[try! Location(x: 3, y: 4)] = .Player2
        referenceBoard[try! Location(x: 5, y: 4)] = .Player2
        referenceBoard[try! Location(x: 3, y: 5)] = .Player2
        referenceBoard[try! Location(x: 4, y: 5)] = .Player1
        referenceBoard[try! Location(x: 5, y: 5)] = .Player2

        // We're going to rotate a copy of the board so we can compare to the
        // original
        var copy = board

        for i in 0 ..< 4 {
            let _ = copy.rotateQuadrant(.BottomRight, inDirection: .Clockwise)
            if i % 2 == 0 {
                XCTAssertEqual(copy, referenceBoard)
            } else {
                XCTAssertEqual(copy, board)
            }
        }

        for i in 0 ..< 4 {
            let _ = copy.rotateQuadrant(.BottomRight, inDirection: .CounterClockwise)
            if i % 2 == 0 {
                XCTAssertEqual(copy, referenceBoard)
            } else {
                XCTAssertEqual(copy, board)
            }
        }
    }

    // MARK: Finding Winning Chains
    func testFindSingleWinningChainHorizontal() {
        var board = Board()
        board[try! Location(x: 4, y: 0)] = .Player1
        board[try! Location(x: 0, y: 1)] = .Player2
        board[try! Location(x: 1, y: 1)] = .Player1
        board[try! Location(x: 2, y: 1)] = .Player1
        board[try! Location(x: 3, y: 1)] = .Player2
        board[try! Location(x: 4, y: 1)] = .Player1
        board[try! Location(x: 5, y: 1)] = .Player2
        board[try! Location(x: 1, y: 2)] = .Player2
        board[try! Location(x: 4, y: 2)] = .Player1

        let chains = board.rotateQuadrant(.TopRight, inDirection: .Clockwise)
        XCTAssertEqual(chains.count, 1)

        let chain = chains[0]
        XCTAssertTrue(chain.owner == .Player1)
        XCTAssertEqual(chain.length, 5)

        let locations = [try! Location(x: 1, y: 1),
                         try! Location(x: 2, y: 1),
                         try! Location(x: 3, y: 1),
                         try! Location(x: 4, y: 1),
                         try! Location(x: 5, y: 1)];
        XCTAssertEqual(chain.locations, locations)
    }

    func testFindSingleWinningChainDiagonalRight() {
        var board = Board()
        board[try! Location(x: 0, y: 0)] = .Player1
        board[try! Location(x: 0, y: 1)] = .Player2
        board[try! Location(x: 1, y: 1)] = .Player1
        board[try! Location(x: 2, y: 1)] = .Player2
        board[try! Location(x: 1, y: 2)] = .Player2
        board[try! Location(x: 2, y: 2)] = .Player1
        board[try! Location(x: 3, y: 3)] = .Player2
        board[try! Location(x: 5, y: 3)] = .Player1
        board[try! Location(x: 4, y: 4)] = .Player1
        board[try! Location(x: 3, y: 5)] = .Player1
        board[try! Location(x: 5, y: 5)] = .Player2

        let chains = board.rotateQuadrant(.BottomRight, inDirection: .CounterClockwise)
        XCTAssertEqual(chains.count, 1)

        let chain = chains[0]
        XCTAssertTrue(chain.owner == .Player1)
        XCTAssertEqual(chain.length, 6)

        let locations = [try! Location(x: 0, y: 0),
                         try! Location(x: 1, y: 1),
                         try! Location(x: 2, y: 2),
                         try! Location(x: 3, y: 3),
                         try! Location(x: 4, y: 4),
                         try! Location(x: 5, y: 5)];
        XCTAssertEqual(chain.locations, locations)
    }

    func testFindSingleWinningChainVertical() {
        var board = Board()
        board[try! Location(x: 4, y: 0)] = .Player1
        board[try! Location(x: 3, y: 1)] = .Player2
        board[try! Location(x: 4, y: 1)] = .Player1
        board[try! Location(x: 4, y: 2)] = .Player1
        board[try! Location(x: 4, y: 3)] = .Player2
        board[try! Location(x: 3, y: 4)] = .Player1
        board[try! Location(x: 4, y: 4)] = .Player1
        board[try! Location(x: 5, y: 4)] = .Player2
        board[try! Location(x: 4, y: 5)] = .Player2

        let chains = board.rotateQuadrant(.BottomRight, inDirection: .Clockwise)
        XCTAssertEqual(chains.count, 1)

        let chain = chains[0]
        XCTAssertTrue(chain.owner == .Player1)
        XCTAssertEqual(chain.length, 5)

        let locations = [try! Location(x: 4, y: 0),
                         try! Location(x: 4, y: 1),
                         try! Location(x: 4, y: 2),
                         try! Location(x: 4, y: 3),
                         try! Location(x: 4, y: 4)];
        XCTAssertEqual(chain.locations, locations)
    }

    func testFindSingleWinningChainDiagonalLeft() {
        var board = Board()
        board[try! Location(x: 4, y: 0)] = .Player1
        board[try! Location(x: 3, y: 1)] = .Player1
        board[try! Location(x: 4, y: 1)] = .Player2
        board[try! Location(x: 0, y: 2)] = .Player1
        board[try! Location(x: 3, y: 2)] = .Player2
        board[try! Location(x: 1, y: 3)] = .Player1
        board[try! Location(x: 2, y: 3)] = .Player2
        board[try! Location(x: 0, y: 4)] = .Player1
        board[try! Location(x: 1, y: 4)] = .Player1

        let chains = board.rotateQuadrant(.TopLeft, inDirection: .CounterClockwise)
        XCTAssertEqual(chains.count, 1)

        let chain = chains[0]
        XCTAssertTrue(chain.owner == .Player1)
        XCTAssertEqual(chain.length, 5)

        let locations = [try! Location(x: 4, y: 0),
                         try! Location(x: 3, y: 1),
                         try! Location(x: 2, y: 2),
                         try! Location(x: 1, y: 3),
                         try! Location(x: 0, y: 4)];
        XCTAssertEqual(chain.locations, locations)
    }

    // TODO: Add unit tests to check for multiple simultaneous chains.
}
