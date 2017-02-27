import UIKit
import SpriteKit

enum DecodeError: ErrorType {
    case MissingKey
    case InvalidType
}

class Shape: SKShapeNode {
    // MARK: - Types of Shapes
    enum ShapeType: Int {
        case Ball
        case Goal
        case Wall
        case Slider
        case Hinge
        case UserWall
    }

    // MARK: - Shape/Use-Specific Values
    static func physicsCategoryForType(type: ShapeType) -> UInt32 {
        switch type {
        case .Ball:   return 0b1;
        case .Goal:   return 0b10;
        case .Wall:   return 0b100;
        case .Slider: return 0b1000;
        case .Hinge:  return 0b10000;
        case .UserWall:  return 0b100000;
        }
    }
    
    static func fillColorForUses(uses: Int) -> UIColor {
        switch uses {
        case 1:   return try! UIColor(hexRepresentation: "#8e44ad");
        case 2:   return try! UIColor(hexRepresentation: "#27ae60");
        case 3:   return try! UIColor(hexRepresentation: "#d35400");
        case 4:   return try! UIColor(hexRepresentation: "#c0392b");
        default:  return try! UIColor(hexRepresentation: "#2c3e50");
        }
    }

    static func pathForType(type: ShapeType, size: CGSize) -> CGPath {
        let frame = CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height)

        switch type {
        case .Ball:
            return CGPathCreateWithEllipseInRect(frame, nil)

        case .Goal:
            fallthrough
            
        case .Hinge:
            fallthrough
            
        case .Wall:
            return CGPathCreateWithRect(frame, nil)

        default:
            return CGPathCreateMutable()
        }
    }

    // MARK: - Properties
    /// The type of the shape object.
    let type: ShapeType

    /// The number of uses the object it has left before it disappears.
    var uses: Int

    // MARK: - Initialization
    init(path: CGPath? = nil, type: ShapeType, uses: Int, size: CGSize, position: CGPoint, rotation: CGFloat, strokeColor: UIColor? = nil, fillColor: UIColor? = nil) {
        self.type = type
        self.uses = uses
        super.init()
        
        if path == nil {
            self.path = Shape.pathForType(type, size: size)
        } else {
            self.path = path
        }
        
        if type == .UserWall {
            self.physicsBody = SKPhysicsBody(edgeChainFromPath: self.path!)
        } else {
            self.physicsBody = SKPhysicsBody(polygonFromPath: self.path!)
        }
        
        self.physicsBody!.categoryBitMask = Shape.physicsCategoryForType(type)
        if type == .Ball {
            self.physicsBody!.dynamic = true
            self.physicsBody!.affectedByGravity = true
            self.physicsBody!.collisionBitMask = ~(Shape.physicsCategoryForType(type) | Shape.physicsCategoryForType(.Goal))
            self.physicsBody!.contactTestBitMask = self.physicsBody!.collisionBitMask | Shape.physicsCategoryForType(.Goal)
            self.zPosition = 1
        } else {
            self.physicsBody!.dynamic = false
            self.physicsBody!.affectedByGravity = false
            self.physicsBody!.restitution = 0.5
        }
        
        if type != .UserWall {
            self.position = position
            self.zRotation = rotation
            if strokeColor == nil {
                self.lineWidth = 0
            } else {
                self.strokeColor = strokeColor!
            }
            
            if fillColor == nil {
                self.fillColor = Shape.fillColorForUses(self.uses)
            } else {
                self.fillColor = fillColor!
            }
        } else {
            self.strokeColor = Shape.fillColorForUses(self.uses)
            self.lineWidth = 5
        }
    }
    
    required init(_ shape: Shape) {
        self.type = shape.type
        self.uses = shape.uses
        super.init()
        
        self.path = CGPathCreateCopy(shape.path!)
        if self.type == .UserWall {
            self.physicsBody = SKPhysicsBody(edgeChainFromPath: self.path!)
        } else {
            self.physicsBody = SKPhysicsBody(polygonFromPath: self.path!)
        }
        
        self.physicsBody!.categoryBitMask = Shape.physicsCategoryForType(type)
        if self.type == .Ball {
            self.physicsBody!.dynamic = true
            self.physicsBody!.affectedByGravity = true
            self.physicsBody!.collisionBitMask = ~(Shape.physicsCategoryForType(type) | Shape.physicsCategoryForType(.Goal))
            self.physicsBody!.contactTestBitMask = self.physicsBody!.collisionBitMask | Shape.physicsCategoryForType(.Goal)
            self.zPosition = 1
        } else {
            self.physicsBody!.dynamic = false
            self.physicsBody!.affectedByGravity = false
            self.physicsBody!.restitution = 0.5
        }
        
        if type != .UserWall {
            self.position = shape.position
            self.zRotation = shape.zRotation
        }
        
        self.strokeColor = shape.strokeColor
        self.fillColor = shape.fillColor
        self.lineWidth = shape.lineWidth
    }
    
    convenience init(json: Dictionary<String, AnyObject>) throws {
        guard json["type"] != nil else { throw DecodeError.MissingKey }

        let type = ShapeType(rawValue: (json["type"] as! NSNumber).integerValue)
        guard type != nil else { throw DecodeError.InvalidType }
        
        let uses: Int = (json["uses"] as? NSNumber) == nil ? 0 : (json["uses"] as! NSNumber).integerValue
        
        guard json["size"] != nil else { throw DecodeError.MissingKey }
        let size = CGSizeFromString(json["size"] as! String)
        
        guard json["position"] != nil else { throw DecodeError.MissingKey }
        let position = CGPointFromString(json["position"] as! String)
        
        var rotation: CGFloat = 0
        if json["rotation"] != nil {
            rotation = CGFloat((json["rotation"] as! NSNumber).doubleValue / 180.0 * M_PI)
        }

        var hex: String? = json["strokeColor"] as! String?
        var strokeColor: UIColor? = nil
        if hex != nil {
            strokeColor = try UIColor(hexRepresentation: hex!)
        }

        hex = json["fillColor"] as! String?
        var fillColor: UIColor? = nil
        if hex != nil {
            fillColor = try UIColor(hexRepresentation: hex!)
        }
        
        self.init(type: type!, uses: uses, size: size, position: position, rotation: rotation, strokeColor: strokeColor, fillColor: fillColor)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func createBallAtPosition(position: CGPoint) -> Shape {
        return Shape(type: .Ball, uses: 0, size: CGSizeMake(30, 30), position: position, rotation: 0)
    }
    
    // MARK: - Copying Shapes
    override func copy() -> AnyObject {
        return self.dynamicType.init(self)
    }
}
