//
//  Board.swift
//  Pentago
//
//  Created by Itai Ferber on 5/13/16.
//  Copyright © 2016 Itai Ferber. All rights reserved.
//

/// Represents one of the two possible directions to rotate a quadrant.
enum RotationDirection {
    case Clockwise
    case CounterClockwise
}

/// Represents the game board being played on.
struct Board: CustomStringConvertible, Equatable {
    // MARK: Properties
    /// The 6×6 grid of marbles the board holds.
    var grid: [[Owner]]

    // MARK: Initialization
    /// Creates a new empty board.
    init() {
        grid = Array(count: 6, repeatedValue: Array(count: 6, repeatedValue: .None))
    }

    // MARK: Indexing into Grid
    /// Sets or gets the marble at the given location.
    subscript(index: Location) -> Owner {
        get {
            return self.grid[index.y][index.x]
        }

        set {
            self.grid[index.y][index.x] = newValue
        }
    }

    // MARK: Error Types
    enum Error: ErrorType {
        case InvalidMarble(message: String)
        case OccupiedLocation(message: String)
    }

    // MARK: Playing Marbles
    /**
     Places the given marble at the given board location.
     
     - parameter marble: The marble to play. Must be of type `.Player1` or
                         `.Player2`.
     - parameter location: The location to play the marble at. Must not already
                           be occupied.
     - throws: `Error.InvalidMarble` if the played marble is of type `.None`.
     - throws: `Error.OccupiedLocation` if the given location already has a
               marble in it.
     */
    mutating func playMarble(marble: Owner, atLocation location: Location) throws {
        guard marble != .None else {
            throw Error.InvalidMarble(message: "Cannot play a marble not belonging to either player.")
        }

        guard self[location] == .None else {
            throw Error.OccupiedLocation(message: "Cannot play over existing marble.")
        }

        self.grid[location.y][location.x] = marble
    }

    // MARK: Rotating Quadrants
    /**
     Rotates the given board quadrant 90 degrees in the given direction.
     
     - parameter quadrant: The board quadrant to rotate.
     - parameter direction: The direction to rotate the quadrant in.
     - returns: An array of winning chains which were created by performing this
                rotation.
     */
    mutating func rotateQuadrant(quadrant: Quadrant, inDirection direction: RotationDirection) -> [Chain] {
        let centerOfRotation: Location
        switch quadrant {
        case .TopLeft:     centerOfRotation = try! Location(x: 1, y: 1)
        case .TopRight:    centerOfRotation = try! Location(x: 4, y: 1)
        case .BottomLeft:  centerOfRotation = try! Location(x: 1, y: 4)
        case .BottomRight: centerOfRotation = try! Location(x: 4, y: 4)
        }

        // Rotation of a quadrant can be performed by transposing the quadrant,
        // and then either reversing the rows or columns, depending on whether
        // the rotation is clockwise or counterclockwise. In either case, since
        // we know we're working with a 3×3 2D array, we can make this
        // transposition without needing to resort to generalized code or loops.

        // Transpose the array:
        // swap(A[0][1], A[1][0])
        let left = try! centerOfRotation.left()
        let up   = try!centerOfRotation.up()
        swap(&self[left], &self[up])

        // swap(A[0][2], A[2][0])
        let lowerLeft  = try! left.down()
        let upperRight = try! up.right()
        swap(&self[lowerLeft], &self[upperRight])

        // swap(A[1][2], A[2][1])
        let right = try! centerOfRotation.right()
        let down  = try! centerOfRotation.down()
        swap(&self[right], &self[down])

        // The array is now transposed. If the rotation is clockwise, we need to
        // reverse each row. If it is counter-clockwise, we need to reverse each
        // column.
        let upperLeft  = try! up.left()
        let lowerRight = try! down.right()
        if direction == .Clockwise {
            // Reverse rows.
            swap(&self[upperLeft], &self[upperRight])
            swap(&self[left],      &self[right])
            swap(&self[lowerLeft], &self[lowerRight])
        } else {
            // Reverse columns.
            swap(&self[upperLeft],  &self[lowerLeft])
            swap(&self[up],         &self[down])
            swap(&self[upperRight], &self[lowerRight])
        }

        // Now that the rotation is complete, we need to look for any winning
        // chains the move has created.
        return findWinningChains()
    }

    // MARK: Checking for Victory
    var isFull: Bool {
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                if self.grid[y][x] == .None {
                    return false
                }
            }
        }

        return true
    }

    /**
     Returns a list of winning chains found in the board.

     - returns: An array of winning chains corresponding to victories on the
                board.
     */
    private func findWinningChains() -> [Chain] {
        var chains = [Chain]()

        // Because chains are symmetrical, we only ever need to look for chains
        // in one of the two directions that they can be interpreted to extend
        // in (i.e. only need to look for horizontal chains going right, because
        // those will also be chains extending left).
        // We're arbitrarily choosing to look for chains going right, down,
        // and down diagonally (left or right). We don't need to scan the entire
        // board repeatedly for these chains, just for chains with starting
        // points within given ranges.

        let generateLocations = { (xRange: Range<Int>, yRange: Range<Int>) -> [Location] in
            var locations = [Location]()
            for y in yRange {
                for x in xRange {
                    locations.append(try! Location(x: x, y: y))
                }
            }

            return locations
        }

        // Look for chains extending rightwards.
        chains.appendContentsOf(findWinningChainsStartingAtLocations(generateLocations(1 ... 1, 0 ..< 6), direction: .Right))

        // Look for chains extending down and to the right.
        let diagonalRightLocations = [try! Location(x: 1, y: 0),
                                      try! Location(x: 0, y: 1),
                                      try! Location(x: 1, y: 1)]
        chains.appendContentsOf(findWinningChainsStartingAtLocations(diagonalRightLocations, direction: .DiagonalRight))

        // Look for chains extending downwards.
        chains.appendContentsOf(findWinningChainsStartingAtLocations(generateLocations(0 ..< 6, 1 ... 1), direction: .Down))

        // Look for chains extending down and to the left.
        let diagonalLeftLocations = [try! Location(x: 4, y: 0),
                                     try! Location(x: 4, y: 1),
                                     try! Location(x: 5, y: 1)]
        chains.appendContentsOf(findWinningChainsStartingAtLocations(diagonalLeftLocations, direction: .DiagonalLeft))

        return chains
    }

    private func findWinningChainsStartingAtLocations(locations: [Location], direction: Chain.Direction) -> [Chain] {
        guard !locations.isEmpty else {
            return []
        }

        var chains = [Chain]()
        for location in locations {
            guard var chain = trackChain(location, direction: direction) else {
                continue
            }

            while let location = chain.previousLocation {
                guard self[location] == chain.owner else {
                    break
                }

                try! chain.extendBeginning()
            }

            if chain.length >= 5 {
                chains.append(chain)
            }
        }

        return chains
    }

    /**
     Returns the longest running chain starting at the given location and
     extending in the given direction.
     
     - parameter location: The starting location of the chain.
     - parameter direction: The direction the chain extends in.
     - returns: The longest single-owner chain starting at the given location
                and extending in the given direction if the owner of the given
                location is not `.None`; `nil` otherwise.
     */
    private func trackChain(location: Location, direction: Chain.Direction) -> Chain? {
        let owner = self[location]
        guard owner != .None else {
            return nil
        }

        var chain = Chain(owner: owner, start: location, direction: direction)
        while let nextLocation = chain.nextLocation {
            if self[nextLocation] == owner {
                try! chain.extendEnd()
            } else {
                break
            }
        }

        return chain
    }

    // MARK: Description
    var description: String {
        var description = ""
        for y in 0 ..< 6 {
            for x in 0 ..< 6 {
                switch self.grid[y][x] {
                case .None:
                    description.append("_" as Character)

                case .Player1:
                    description.append("1" as Character)

                case .Player2:
                    description.append("2" as Character)
                }

                description.append(" " as Character)

                if x == 2 {
                    description.appendContentsOf("| ")
                }
            }

            if y < 5 {
                description.append("\n" as Character)
            }

            if y == 2 {
                description.appendContentsOf("-------------\n")
            }
        }

        return description
    }
}

func ==(lhs: Board, rhs: Board) -> Bool {
    for y in 0 ..< 6 {
        for x in 0 ..< 6 {
            if lhs.grid[y][x] != rhs.grid[y][x] {
                return false
            }
        }
    }

    return true
}
