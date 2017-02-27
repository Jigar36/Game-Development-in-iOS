import SpriteKit

class Level: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties
    var shapes: [Shape] = []
    let ballVelocity: CGVector
    let ball: Shape
    let goal: Shape
    var sequence: [Int] = []
    var sequenceIndex: Int = 0
    var sequenceLabels: [SKNode] = []
    var gravityLabel: SKNode! = nil
    var arrow: SKShapeNode! = nil
    var userPath: UIBezierPath! = nil
    var userWall: SKShapeNode! = nil

    let tapSoundAction: SKAction
    let winSoundAction: SKAction

    var levelDelegate: LevelDelegate? = nil

    // MARK: - Initialization
    init(size: CGSize, json: Dictionary<String, AnyObject>) throws {
        // Put the ball in place.
        guard let properties = json["ball"] as? NSDictionary else { throw DecodeError.MissingKey }
        guard let positionString = properties["position"] as? String else { throw DecodeError.MissingKey }
        guard let velocityString = properties["velocity"] as? String else { throw DecodeError.MissingKey }

        let ballPosition = CGPointFromString(positionString)
        self.ballVelocity = CGVectorFromString(velocityString)
        self.ball = Shape.createBallAtPosition(ballPosition)
        
        // Set up arrow.
        let arrowTip = CGPointMake(self.ball.position.x + self.ballVelocity.dx / 12, self.ball.position.y + self.ballVelocity.dy / 12)
        self.arrow = Level.arrowNodeFromPoint(self.ball.position, toPoint: arrowTip)

        // Add and set up goal.
        guard let goalDefinition = json["goal"] as? NSDictionary else { throw DecodeError.MissingKey }
        self.goal = try Shape(json: goalDefinition as! Dictionary<String, AnyObject>)

        // Set up sounds.
        self.tapSoundAction = SKAction.playSoundFileNamed("tap.caf", waitForCompletion: false)
        self.winSoundAction = SKAction.playSoundFileNamed("success.caf", waitForCompletion: false)

        // Everything else is initialized implicitly above.
        super.init(size: size)
        
        // We can now actually add shapes to the scene.
        self.addChild(self.ball)
        self.addChild(self.arrow)
        self.addChild(self.goal)
        self.goal.fillColor = UIColor.clearColor()
        self.goal.lineWidth = 0

        let pattern: [CGFloat] = [5, 2]
        let dashedPath = CGPathCreateCopyByDashingPath(self.goal.path!, nil, 0, pattern, 2)
        let dashedNode = SKShapeNode(path: dashedPath!, centered: true)
        dashedNode.strokeColor = try! UIColor(hexRepresentation: "#27ae60")
        dashedNode.fillColor = UIColor.clearColor()
        dashedNode.lineWidth = 2
        self.goal.addChild(dashedNode)

        guard json["shapes"] != nil else { throw DecodeError.MissingKey }
        for representation in json["shapes"] as! [NSDictionary] {
            let shape = try Shape(json: representation as! Dictionary<String, AnyObject>)
            self.shapes.append(shape)
            self.addChild(shape)
        }
        
        // Load sequence.
        guard json["sequence"] != nil else { throw DecodeError.MissingKey }
        for uses in json["sequence"] as! [NSInteger] {
            self.sequence.append(uses)
        }

        // Listen for contact notifications.
        self.physicsWorld.contactDelegate = self
        
        // Optionally turn off gravity.
        if json["gravity"] != nil && !(json["gravity"] as! NSNumber).boolValue {
            self.physicsWorld.gravity = CGVectorMake(0, 0)
        }
        
        // Show gravity indicator.
        self.gravityLabel = Level.createGravityLabelForGravity(self.physicsWorld.gravity.dy)
        self.addChild(self.gravityLabel)
        self.gravityLabel.position = CGPointMake(36, self.frame.size.height - 36)
        
        // Show sequence indicators, use same height for border as gravity indicator
        self.sequenceLabels.removeAll()
        for i in 0 ..< sequence.count {
            let sequenceLabel = SKLabelNode(fontNamed: "Avenir-Medium")
            sequenceLabel.fontColor = Shape.fillColorForUses(self.sequence[i])
            sequenceLabel.text = String(self.sequence[i])
            sequenceLabel.fontSize = 18
            sequenceLabel.position = CGPointMake(0, 0)
            let borderNode = SKShapeNode(path: CGPathCreateWithRoundedRect(CGRectMake(-12, -self.gravityLabel.frame.height/2 + 8, 24, self.gravityLabel.frame.height), 5, 5, nil))
            borderNode.position = CGPointMake(self.frame.size.width - (CGFloat(self.sequence.count - i)) * 32, self.frame.size.height - 36)
            borderNode.strokeColor = sequenceLabel.fontColor!
            borderNode.lineWidth = 2
            borderNode.addChild(sequenceLabel)
            self.addChild(borderNode)
            self.sequenceLabels.append(borderNode)
        }

        self.paused = true
    }
    
    required init(_ level: Level) {
        for shape in level.shapes {
            self.shapes.append(shape.copy() as! Shape)
        }

        self.ballVelocity = level.ballVelocity
        self.ball = level.ball.copy() as! Shape
        self.goal = level.goal.copy() as! Shape
        self.goal.addChild(level.goal.children[0].copy() as! SKNode)
        
        self.sequence = level.sequence
        self.sequenceIndex = 0
        for label in level.sequenceLabels {
            self.sequenceLabels.append(label.copy() as! SKNode)
        }
        
        self.arrow = level.arrow.copy() as! SKShapeNode
        self.userPath = nil

        self.tapSoundAction = level.tapSoundAction.copy() as! SKAction
        self.winSoundAction = level.winSoundAction.copy() as! SKAction
        
        super.init(size: level.size)
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = level.physicsWorld.gravity
        
        self.addChild(self.ball)
        self.addChild(self.goal)
        self.addChild(self.arrow)
        
        for shape in self.shapes {
            self.addChild(shape)
        }
        
        for i in 0 ..< self.sequence.count {
            let label = self.sequenceLabels[i] as! SKShapeNode
            label.strokeColor = Shape.fillColorForUses(self.sequence[i])
            let labelText = label.children[0] as! SKLabelNode
            labelText.fontColor = label.strokeColor
            self.addChild(label)
        }
        
        self.gravityLabel = Level.createGravityLabelForGravity(self.physicsWorld.gravity.dy)
        self.addChild(self.gravityLabel)
        self.gravityLabel.position = CGPointMake(56, self.frame.size.height - 36)
        
        self.backgroundColor = level.backgroundColor
        self.paused = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Level Setup
    override func willMoveFromView(view: SKView) {
        self.paused = true
    }

    override func didMoveToView(view: SKView) {
        self.paused = true
    }

    // MARK: - Level Copying
    override func copy() -> AnyObject {
        return self.dynamicType.init(self)
    }

    // MARK: - Level Setup
    func launch() {
        self.userInteractionEnabled = false
        self.arrow.removeFromParent()
        self.ball.physicsBody!.velocity = self.ballVelocity
        self.paused = false
    }

    // MARK: - Responding to User Touches
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.userPath = UIBezierPath()
        self.userPath.moveToPoint(touches.first!.locationInNode(self))
        if self.userWall != nil {
            self.userWall.removeFromParent()
        }
        
        self.touchesMoved(touches, withEvent: event)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.userPath.addLineToPoint(touches.first!.locationInNode(self))
        if self.userWall != nil {
            self.userWall.removeFromParent()
        }
        
        self.userWall = Shape(path: self.userPath.CGPath, type: .UserWall, uses: self.sequence[self.sequenceIndex], size: CGSizeZero, position: CGPointZero, rotation: 0)
        self.userWall.lineJoin = .Bevel
        self.userWall.lineCap = .Round
        self.addChild(self.userWall)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.userPath = nil
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Gray-out sequence label
        self.userWall = nil
        
        let label = sequenceLabels[self.sequenceIndex] as? SKShapeNode
        label?.strokeColor = try! UIColor(hexRepresentation: "#bdc3c7")
        let labelText = label?.children[0] as? SKLabelNode
        labelText?.fontColor = label?.strokeColor
        
        self.sequenceIndex += 1
        if (self.sequenceIndex == self.sequence.count) {
            launch()
        }
    }

    // MARK: - SKPhysicsDelegate Methods
    func didBeginContact(contact: SKPhysicsContact) {}
    
    func didEndContact(contact: SKPhysicsContact) {
        // Decrement uses on shapes
        if contact.bodyA.categoryBitMask != Shape.physicsCategoryForType(Shape.ShapeType.Goal) && contact.bodyB.categoryBitMask != Shape.physicsCategoryForType(Shape.ShapeType.Goal) {
            self.runAction(self.tapSoundAction)
        }
        if contact.bodyA.categoryBitMask != Shape.physicsCategoryForType(Shape.ShapeType.Ball) {
            if let shape = contact.bodyA.node as? Shape {
                if shape.uses == 1 {
                    shape.removeFromParent()
                }
                shape.uses = (shape.uses > 0) ? shape.uses - 1 : 0
                if shape.type == Shape.ShapeType.UserWall {
                    shape.strokeColor = Shape.fillColorForUses(shape.uses)
                } else if shape.type != Shape.ShapeType.Goal {
                    shape.fillColor = Shape.fillColorForUses(shape.uses)
                }
            }
        } else if contact.bodyB.categoryBitMask != Shape.physicsCategoryForType(Shape.ShapeType.Ball){
            if let shape = contact.bodyB.node as? Shape {
                if shape.uses == 1 {
                    shape.removeFromParent()
                }
                shape.uses = (shape.uses > 0) ? shape.uses - 1 : 0
                if shape.type == Shape.ShapeType.UserWall {
                    shape.strokeColor = Shape.fillColorForUses(shape.uses)
                } else if shape.type != Shape.ShapeType.Goal {
                    shape.fillColor = Shape.fillColorForUses(shape.uses)
                }
            }
        }
    }

    // MARK: - Physics Simulations
    override func update(currentTime: NSTimeInterval) {
        if CGRectInset(self.goal.frame, -15, -15).contains(self.ball.frame) {
            // TODO - Smoothly transition to next level
            var shapesDone = true
            for node in self.children {
                if let shape = node as? Shape {
                    if shape.uses > 0 {
                        shapesDone = false
                        break
                    }
                }
            }
            
            if shapesDone {
                self.ball.runAction(SKAction.fadeOutWithDuration(0.05)) {
                    self.ball.removeFromParent()

                    let resourcePath: String! = NSBundle.mainBundle().pathForResource("Confetti", ofType: "sks")
                    if resourcePath == nil {
                        fatalError("Unable to get confetti resource path.")
                    }

                    let confetti = NSKeyedUnarchiver.unarchiveObjectWithFile(resourcePath) as! SKEmitterNode
                    confetti.alpha = 1.0
                    confetti.targetNode = self.goal
                    self.goal.addChild(confetti)

                    self.runAction(self.winSoundAction)
                    let totalTime: NSTimeInterval = Double(CGFloat(confetti.numParticlesToEmit) / confetti.particleBirthRate + confetti.particleLifetime + confetti.particleLifetimeRange / 2)
                    confetti.runAction(SKAction.waitForDuration(totalTime)) {
                        self.levelDelegate!.userDidCompleteLevel(self)
                    }
                }
            }
        }
        
        // Reset if ball falls off screen
        if !self.frame.intersects(self.ball.frame) {
            self.paused = true
            self.levelDelegate?.userDidLoseLevel(self)
        }
        
        for shape in self.shapes {
            if shape.type == Shape.ShapeType.Hinge {
                shape.zRotation += CGFloat(3.0/60)
            }
        }
    }

    // MARK: - Drawing
    static func arrowNodeFromPoint(origin: CGPoint, toPoint destination: CGPoint) -> SKShapeNode {
        let arrowPath = Level.arrowPathFromPoint(origin, toPoint: destination)
        let arrow = SKShapeNode(path: arrowPath.CGPath)
        arrow.strokeColor = try! UIColor(hexRepresentation: "#2c3e50d5")
        arrow.lineCap = .Round
        arrow.lineJoin = .Bevel
        arrow.lineWidth = 3
        arrow.zPosition = -1
        return arrow
    }

    static func arrowPathFromPoint(origin: CGPoint, toPoint destination: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(origin)
        path.addLineToPoint(destination)

        let angle = atan2(destination.y - origin.y, destination.x - origin.x)
        let distance = hypot(destination.y - origin.y, destination.x - origin.x)
        let tipLength = distance / 4

        let tip1Point = CGPointMake(destination.x + cos(angle + 5 * CGFloat(M_PI_2) / 3) * tipLength, destination.y + sin(angle + 5 * CGFloat(M_PI_2) / 3) * tipLength)
        let tip2Point = CGPointMake(destination.x + cos(angle - 5 * CGFloat(M_PI_2) / 3) * tipLength, destination.y + sin(angle - 5 * CGFloat(M_PI_2) / 3) * tipLength)
        path.moveToPoint(tip1Point)
        path.addLineToPoint(destination)
        path.addLineToPoint(tip2Point)
        return path
    }

    static func createGravityLabelForGravity(gravity: CGFloat) -> SKNode {
        let gravityLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        gravityLabel.fontColor = try! (gravity == 0 ? UIColor(hexRepresentation: "#bdc3c7") : UIColor(hexRepresentation: "#2ecc71"))
        gravityLabel.text = "Gravity"
        gravityLabel.fontSize = 18
        gravityLabel.position = CGPointMake(0, 0)

        let borderNode = SKShapeNode(path: CGPathCreateWithRoundedRect(CGRectMake(-gravityLabel.frame.width/2 - 5, -gravityLabel.frame.height/2 + 5, gravityLabel.frame.width + 10, gravityLabel.frame.height + 5), 5, 5, nil))
        borderNode.strokeColor = gravityLabel.fontColor!
        borderNode.lineWidth = 2
        borderNode.addChild(gravityLabel)
        return borderNode
    }
}

protocol LevelDelegate {
    func userDidCompleteLevel(level: Level)
    func userDidLoseLevel(level: Level)
}
