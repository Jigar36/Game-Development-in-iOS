//
//  Rock.m
//  Asteroids
//
//  Created by Zhaolin Yu on 2/18/16.
//  Copyright © 2016 Franklin Yu. All rights reserved.
//

#import "Rock.h"
#import "SharedConstants.h"

@implementation Rock

- (void)setSpeedVector:(CGVector)speedVector {
	_speedVector = speedVector;
	SKAction *drift = [SKAction moveBy:speedVector duration:1];
	[self removeActionForKey:@"drift"];
	[self runAction:[SKAction repeatActionForever:drift] withKey:@"drift"];
}

+ (Rock *)rockWithPosition:(CGPoint)position {
	return [self rockWithPosition:position andRadius:50];
}

+ (Rock *)rockWithPosition:(CGPoint)position andRadius:(CGFloat)radius {
	if (radius < 3) {
		return nil;
	}
	Rock *rock = [self shapeNodeWithCircleOfRadius:radius];
	if (rock) {
		rock.position = position;
		rock.radius = radius;
		CGFloat direction = drand48() * M_PI * 2;
		rock.speedVector = CGVectorMake(5 * sin(direction), 5 * cos(direction));
		rock.strokeColor = [SKColor whiteColor];
		rock.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
		rock.physicsBody.categoryBitMask = obstacleCategory;
		rock.physicsBody.contactTestBitMask = shipCategory | projectileCategory;
	}
	return rock;
}

- (Rock *)newSubrockWithNormal:(CGVector)normal inDirection:(CGFloat)dir {
	Rock *rock = [Rock rockWithPosition:self.position andRadius:_radius - 10];
	if (rock) {
		CGFloat speedRate = dir * 10;
		CGVector speed = _speedVector;
		speed.dx += normal.dy * speedRate;
		speed.dy += normal.dx * speedRate;
		rock.speedVector = speed;
		CGPoint point = self.position;
		point.x += normal.dy * _radius * dir;
		point.y += normal.dx * _radius * dir;
		rock.position = point;
	}
	return rock;
}

@end
