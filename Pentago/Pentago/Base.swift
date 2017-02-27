//
//  Base.swift
//  Pentago
//
//  Created by Itai Ferber on 5/14/16.
//  Copyright © 2016 Itai Ferber. All rights reserved.
//

/// Represents the owner of a marble played on a given move.
enum Owner: Int {
    case None
    case Player1
    case Player2
}

/// Represents one of the four quadrants on the game board.
enum Quadrant: Int {
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
}

/**
 Represents a location on the game grid, with the top-left corner of the grid
 being (0,0), and the lower-right corner being (5,5).
 */
struct Location: CustomStringConvertible, Equatable {
    // MARK: Properties
    /// The x-coordinate of the location.
    let x: Int

    /// The y-coordinate of the location
    let y: Int

    // MARK: Error Types
    enum Error: ErrorType {
        case InvalidCoordinate(message: String)
    }

    // MARK: Initialization
    /**
     Creates a new location with the given x- and y-coordinates.

     - parameters:
     - x: The x-coordinate of the location. Must be a valid x-coordinate on
     the game grid (i.e. `0 <= x < 6`).
     - y: The y-coordinate of the location. Must be a valid y-coordinate on
     the game grid (i.e. `0 <= y < 6`).
     */
    init(x: Int, y: Int) throws {
        guard 0 <= x && x < 6 else {
            throw Error.InvalidCoordinate(message: "Cannot create a location with an x-coordinate not on the game grid.")
        }

        guard 0 <= y && y < 6 else {
            throw Error.InvalidCoordinate(message: "Cannot create a location with a y-coordinate not on the game grid.")
        }

        self.x = x
        self.y = y
    }

    // MARK: Converting to Quadrants
    var quadrant: Quadrant {
        if x < 3 && y < 3 {
            return .TopLeft
        } else if x >= 3 && y < 3 {
            return .TopRight
        } else if x < 3 && y >= 3 {
            return .BottomLeft
        } else {
            return .BottomRight
        }
    }

    // MARK: Relative Locations
    /// Returns the location directly above the receiver.
    func up() throws -> Location {
        return try Location(x: self.x, y: self.y - 1)
    }

    /// Returns the location directly below the receiver.
    func down() throws -> Location {
        return try Location(x: self.x, y: self.y + 1)
    }

    /// Returns the location directly to the left of the receiver.
    func left() throws -> Location {
        return try Location(x: self.x - 1, y: self.y)
    }

    /// Returns the location directly to the right of the receiver.
    func right() throws -> Location {
        return try Location(x: self.x + 1, y: self.y)
    }

    // MARK: Description
    var description: String {
        return "(\(self.x), \(self.y))"
    }
}

// MARK: Equality
func ==(lhs: Location, rhs: Location) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
