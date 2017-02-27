//
//  Rock.h
//  Asteroids
//
//  Created by Zhaolin Yu on 2/18/16.
//  Copyright © 2016 Franklin Yu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Rock : SKShapeNode

@property CGFloat radius;
@property (nonatomic) CGVector speedVector;

+ (Rock *)rockWithPosition:(CGPoint)position;
+ (Rock *)rockWithPosition:(CGPoint)position andRadius:(CGFloat)radius;

- (Rock *)newSubrockWithNormal:(CGVector)normal inDirection:(CGFloat)dir;

@end
