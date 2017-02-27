//
//  GameView.swift
//  Pentago
//
//  Created by Itai Ferber on 5/16/16.
//  Copyright © 2016 Itai Ferber. All rights reserved.
//

import UIKit

extension UIColor {
    static func colorForPlayer(player: Owner) -> UIColor {
        switch player {
        case .None:    return try! UIColor(hexRepresentation: "#2C3E50")
        case .Player1: return try! UIColor(hexRepresentation: "#2ECC71")
        case .Player2: return try! UIColor(hexRepresentation: "#3498DB")
        }
    }

    static func hexColorForPlayer(player: Owner) -> UInt {
        switch player {
        case .None:    return 0x2C3E50
        case .Player1: return 0x2ECC71
        case .Player2: return 0x3498DB
        }
    }
}

protocol GameViewDelegate {
    func playerDidPlaceMarble(player: Owner)
    func player(player: Owner, didCompleteTurnWithWinningChains chains: [Chain])
    func playerDidFillBoardWithNoVictory()
}

protocol QuadrantDelegate {
    func canPlayMarbleInQuadrant(quadrant: Quadrant, atLocation location: Location) -> Bool
    func currentPlayerForPlay() -> Owner
    func currentPlayerPlayedMarbleInQuadrant(quadrant: Quadrant, atLocation location: Location)
    func currentPlayerDidRotateQuadrant(quadrant: Quadrant, direction: RotationDirection)
}

class GameView: UIView, QuadrantDelegate {
    // MARK: Inner Classes
    private class QuadrantView: UIView {
        // MARK: Properties
        let identity: Quadrant
        var delegate: QuadrantDelegate? = nil

        private let rotationRecognizer: UIRotationGestureRecognizer
        private let tapRecognizer: UITapGestureRecognizer
        private var spaces = [[CAShapeLayer]]()

        // MARK: Initialization
        init(identity: Quadrant, size: CGSize) {
            self.identity = identity
            self.rotationRecognizer = UIRotationGestureRecognizer()
            self.tapRecognizer = UITapGestureRecognizer()

            let frame = CGRectMake(0, 0, size.width, size.height)
            super.init(frame: frame)

            // Set up gesture recognizers.
            self.rotationRecognizer.addTarget(self, action: #selector(rotate))
            self.addGestureRecognizer(self.rotationRecognizer)
            self.tapRecognizer.addTarget(self, action: #selector(tap))
            self.addGestureRecognizer(self.tapRecognizer)

            // Set up the layer to house all the spaces.
            let layer = CAShapeLayer()
            layer.path = CGPathCreateWithRoundedRect(frame, 8, 8, nil)
            layer.fillColor = UIColor.clearColor().CGColor
            layer.strokeColor = try! UIColor(hexRepresentation: "#15A085").CGColor
            layer.lineWidth = 3
            self.layer.addSublayer(layer)

            // Set up the spaces.
            let padding = CGFloat(16)
            let holeSize = CGSizeMake((size.width - 4 * padding) / 3, (size.height - 4 * padding) / 3)
            for y in 0 ..< 3 {
                var spaces = [CAShapeLayer]()
                for x in 0 ..< 3 {
                    let space = CAShapeLayer()
                    space.path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, holeSize.width, holeSize.height), nil)
                    space.bounds = CGPathGetBoundingBox(space.path!)
                    space.position = CGPointMake(space.bounds.size.width / 2 + padding + (holeSize.width + padding) * CGFloat(x),
                                                 space.bounds.size.height / 2 + padding + (holeSize.height + padding) * CGFloat(y))

                    space.fillColor = layer.fillColor
                    space.strokeColor = layer.strokeColor
                    space.lineWidth = layer.lineWidth
                    layer.addSublayer(space)
                    spaces.append(space)
                }

                self.spaces.append(spaces)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // Setting Up State
        func allowMarblePlacement() {
            self.tapRecognizer.enabled = true
            self.rotationRecognizer.enabled = false
        }

        func allowRotation() {
            self.tapRecognizer.enabled = false
            self.rotationRecognizer.enabled = true
        }

        // MARK: Gesture Recognition
        private var previousRotation = CGFloat(0)
        @objc func rotate(recognizer: UIRotationGestureRecognizer) {
            if recognizer.state == .Began {
                previousRotation = 0
            }

            var rotation = recognizer.rotation
            if rotation < -CGFloat(M_PI_2) {
                rotation = -CGFloat(M_PI_2)
            } else if CGFloat(M_PI_2) < rotation {
                rotation = CGFloat(M_PI_2)
            }

            var committing = false
            if recognizer.state == .Ended {
                if rotation < -CGFloat(M_PI_4) {
                    rotation = -CGFloat(M_PI_2)
                } else if CGFloat(M_PI_4) < rotation {
                    rotation = CGFloat(M_PI_2)
                } else {
                    rotation = 0
                }

                committing = true
            }

            let rotationDelta = rotation - previousRotation
            previousRotation = rotation

            let oldTransform = self.layer.transform
            let transform = CATransform3DMakeRotation(atan2(oldTransform.m12, oldTransform.m11) + rotationDelta, 0, 0, 1)
            if committing {
                let direction: RotationDirection = rotation == CGFloat(M_PI_2) ? .Clockwise : .CounterClockwise
                UIView.animateWithDuration(0.25, animations: {self.layer.transform = transform}) { (_: Bool) in
                    if rotation != 0 {
                        self.delegate?.currentPlayerDidRotateQuadrant(self.identity, direction: direction)
                    }
                }

                // Rotate the actual space array itself.
                swap(&self.spaces[0][1], &self.spaces[1][0])
                swap(&self.spaces[0][2], &self.spaces[2][0])
                swap(&self.spaces[1][2], &self.spaces[2][1])

                if direction == .Clockwise {
                    // Reverse rows.
                    swap(&self.spaces[0][0], &self.spaces[0][2])
                    swap(&self.spaces[1][0], &self.spaces[1][2])
                    swap(&self.spaces[2][0], &self.spaces[2][2])
                } else {
                    // Reverse columns.
                    swap(&self.spaces[0][0], &self.spaces[2][0])
                    swap(&self.spaces[0][1], &self.spaces[2][1])
                    swap(&self.spaces[0][2], &self.spaces[2][2])
                }
            } else {
                self.layer.transform = transform
            }
        }

        @objc func tap(recognizer: UITapGestureRecognizer) {
            let tapLocation = recognizer.locationInView(self)
            var testLocation: Location? = nil
            var testSpace: CAShapeLayer? = nil
            for y in 0 ..< 3 {
                for x in 0 ..< 3 {
                    let space = self.spaces[y][x]
                    if space.frame.contains(tapLocation) {
                        testSpace = space
                        testLocation = try! Location(x: x, y: y)
                        break
                    }
                }
            }

            guard let space = testSpace else { return }
            guard let location = testLocation else { return }
            guard let delegate = self.delegate else { return }

            if delegate.canPlayMarbleInQuadrant(self.identity, atLocation: location) {
                let marble = CAShapeLayer()
                marble.path = CGPathCreateWithEllipseInRect(CGRectInset(space.bounds, 4, 4), nil)
                marble.bounds = CGPathGetBoundingBox(marble.path!)
                marble.position = CGPointMake(marble.bounds.size.width / 2 + 4, marble.bounds.size.height / 2 + 4)
                marble.fillColor = UIColor.colorForPlayer(delegate.currentPlayerForPlay()).CGColor
                marble.lineWidth = 0
                space.addSublayer(marble)

                delegate.currentPlayerPlayedMarbleInQuadrant(self.identity, atLocation: location)
            }
        }
    }

    // MARK: Properties
    /// The board the game view represents.
    private var board = Board()

    /// The individual quadrant layers that make up the view's quadrants.
    private var quadrants = [QuadrantView]()

    /// The current player making moves on the board.
    private var currentPlayer: Owner = .Player1

    /**
     A delegate which receives notifications about the current state of the game.
     */
    var delegate: GameViewDelegate? = nil

    // MARK: Initialization
    override init(frame: CGRect) {
        let usableFrame: CGRect
        if frame.width < frame.height {
            usableFrame = CGRectInset(frame, 0, (frame.height - frame.width) / 2)
        } else {
            usableFrame = CGRectInset(frame, (frame.width - frame.height) / 2, 0)
        }

        super.init(frame: usableFrame)

        let padding = CGFloat(16)
        let quadrantSize = CGSizeMake((self.frame.size.width - padding) / 2,
                                      (self.frame.size.height - padding) / 2)
        for identity in [.TopLeft, .TopRight, .BottomLeft, .BottomRight] as [Quadrant] {
            let quadrant = QuadrantView(identity: identity, size: quadrantSize)
            self.addSubview(quadrant)
            self.quadrants.append(quadrant)
            quadrant.delegate = self
            quadrant.allowMarblePlacement()

            quadrant.translatesAutoresizingMaskIntoConstraints = false
            quadrant.widthAnchor.constraintEqualToConstant(quadrantSize.width).active = true
            quadrant.heightAnchor.constraintEqualToConstant(quadrantSize.height).active = true
            switch identity {
            case .TopLeft:
                quadrant.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
                quadrant.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true

            case .TopRight:
                quadrant.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
                quadrant.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true

            case .BottomLeft:
                quadrant.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
                quadrant.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true

            case .BottomRight:
                quadrant.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
                quadrant.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
            }
        }
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Calculating Quadrant Offsets
    private func translateLocation(location: Location, fromQuadrant quadrant: Quadrant) -> Location {
        var xOffset = 0
        var yOffset = 0
        switch quadrant {
        case .TopRight:
            xOffset = 3

        case .BottomLeft:
            yOffset = 3

        case .BottomRight:
            xOffset = 3
            yOffset = 3

        default: break
        }

        return try! Location(x: location.x + xOffset, y: location.y + yOffset)
    }

    private func translateLocation(location: Location, toQuadrant quadrant: Quadrant) -> Location {
        var xOffset = 0
        var yOffset = 0
        switch quadrant {
        case .TopRight:
            xOffset = 3

        case .BottomLeft:
            yOffset = 3

        case .BottomRight:
            xOffset = 3
            yOffset = 3

        default: break
        }

        return try! Location(x: location.x - xOffset, y: location.y - yOffset)
    }

    // MARK: Quadrant Delegate Methods
    func canPlayMarbleInQuadrant(quadrant: Quadrant, atLocation location: Location) -> Bool {
        let absoluteLocation = self.translateLocation(location, fromQuadrant: quadrant)
        return self.board[absoluteLocation] == .None
    }

    func currentPlayerForPlay() -> Owner {
        return self.currentPlayer
    }

    func currentPlayerPlayedMarbleInQuadrant(quadrant: Quadrant, atLocation location: Location) {
        let absoluteLocation = self.translateLocation(location, fromQuadrant: quadrant)
        try! self.board.playMarble(self.currentPlayer, atLocation: absoluteLocation)

        for quadrant in self.quadrants {
            quadrant.allowRotation()
        }

        self.delegate?.playerDidPlaceMarble(self.currentPlayer)
    }

    func currentPlayerDidRotateQuadrant(quadrant: Quadrant, direction: RotationDirection) {
        for quadrant in self.quadrants {
            quadrant.userInteractionEnabled = false
            quadrant.allowMarblePlacement()
        }

        let chains = self.board.rotateQuadrant(quadrant, inDirection: direction)
        guard !chains.isEmpty else {
            // No winning chains. Just switch to the next player and continue.
            if self.board.isFull {
                self.delegate?.playerDidFillBoardWithNoVictory()
            } else {
                self.delegate?.player(self.currentPlayer, didCompleteTurnWithWinningChains: chains)
                self.currentPlayer = self.currentPlayer == .Player1 ? .Player2 : .Player1
                for quadrant in self.quadrants {
                    quadrant.userInteractionEnabled = true
                }
            }

            return
        }

        self.userInteractionEnabled = false

        // Inform the game controller after the animations occur.
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.delegate?.player(self.currentPlayer, didCompleteTurnWithWinningChains: chains)
        }

        for chain in chains {
            var time: CFTimeInterval = CACurrentMediaTime()
            for location in chain.locations {
                let quadrant = self.quadrants[location.quadrant.rawValue]
                let locationInQuadrant = self.translateLocation(location, toQuadrant: location.quadrant)
                let space = quadrant.spaces[locationInQuadrant.y][locationInQuadrant.x]

                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = 0
                animation.toValue = 1
                animation.duration = 0.25
                animation.beginTime = time
                space.addAnimation(animation, forKey: animation.keyPath)

                time += animation.duration
            }
        }

        CATransaction.commit()
    }
}
