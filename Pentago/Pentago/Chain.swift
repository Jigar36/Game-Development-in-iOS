//
//  Chain.swift
//  Pentago
//
//  Created by Itai Ferber on 5/14/16.
//  Copyright © 2016 Itai Ferber. All rights reserved.
//

struct Chain {
    // MARK: Directions
    /// The possible directions a winning chain can extend into.
    enum Direction {
        case Right
        case DiagonalRight
        case Down
        case DiagonalLeft
    }

    // MARK: Error Types
    enum Error: ErrorType {
        case InvalidExtension(message: String)
    }

    // MARK: Properties
    /// The owner of the chain.
    let owner: Owner

    /// The location the chain starts from.
    var start: Location

    /// The direction the chain extends in.
    let direction: Direction

    /// The length of the chain.
    var length: Int

    // MARK: Initialization
    /**
     Creates a new chain with the given owner, starting at the given board
     location, extending in the given direction.
    */
    init(owner: Owner, start: Location, direction: Direction) {
        self.owner = owner
        self.start = start
        self.direction = direction
        self.length = 1
    }

    // MARK: Extending a Chain
    /**
     Extends the start of the chain in the opposite direction that the chain
     points.
     
     - throws: `Error.InvalidExtension` if extending the chain would cause it to
               extend off of the game grid.
     */
    mutating func extendBeginning() throws {
        guard let location = self.previousLocation else {
            throw Error.InvalidExtension(message: "Cannot extend start of chain past game grid.")
        }

        self.start = location
        self.length += 1
    }

    /**
     Extends the end of the chain in the chain's direction by one location.
     
     - throws: `Error.InvalidExtension` if extending the chain would cause it to
               extend off of the game grid.
     */
    mutating func extendEnd() throws {
        // We have to validate that we're extending to a valid location.
        guard self.nextLocation != nil else {
            throw Error.InvalidExtension(message: "Cannot extend end of chain past game grid.")
        }

        // Nothing threw; this location must be valid. Okay to increment length.
        self.length += 1
    }

    // MARK: Getting Chain Locations
    /**
     Returns the locations this chain represents, in direction order.
     
     - returns: An array of locations starting with the start location of the
                chain and extending in the chain's direction.
     */
    var locations: [Location] {
        if self.length == 0 {
            return []
        }

        let xRange: [Int]
        let yRange: [Int]
        switch self.direction {
        case .Right:
            xRange = [Int](self.start.x ... (self.start.x + self.length))
            yRange = Array(count: self.length, repeatedValue: self.start.y)

        case .DiagonalRight:
            xRange = [Int](self.start.x ... (self.start.x + self.length - 1))
            yRange = [Int](self.start.y ... (self.start.y + self.length - 1))

        case .Down:
            xRange = Array(count: self.length, repeatedValue: self.start.x)
            yRange = [Int](self.start.y ... (self.start.y + self.length))

        case .DiagonalLeft:
            xRange = [Int]((self.start.x - self.length + 1) ... self.start.x)
            yRange = (self.start.y ... (self.start.y + self.length - 1)).reverse()
        }

        var locations = [Location]()
        for (x, y) in zip(xRange, yRange) {
            locations.append(try! Location(x: x, y: y))
        }

        if self.direction == .DiagonalLeft {
            return locations.reverse()
        } else {
            return locations
        }
    }

    /**
     Returns the location the chain would extend to with `extendBeginning()`, if
     valid.
     
     - returns: A valid `Location` object if the previous location in this
                direction is valid; `nil` otherwise.
     */
    var previousLocation: Location? {
        do {
            switch self.direction {
            case .Right:
                return try self.start.left()

            case .DiagonalRight:
                return try self.start.left().up()

            case .Down:
                return try self.start.up()

            case .DiagonalLeft:
                return try self.start.right().up()
            }
        } catch {
            return nil
        }
    }

    /**
     Returns the next location the chain would extend in, if valid.
     
     - returns: A valid `Location` object if the next location in this direction
                is valid; `nil` otherwise.
     */
    var nextLocation: Location? {
        var x = self.start.x
        var y = self.start.y
        switch self.direction {
        case .Right:
            x += self.length

        case .DiagonalRight:
            x += self.length
            y += self.length

        case .Down:
            y += self.length

        case .DiagonalLeft:
            x -= self.length
            y += self.length
        }

        do {
            return try Location(x: x, y: y)
        } catch {
            return nil
        }
    }
}
