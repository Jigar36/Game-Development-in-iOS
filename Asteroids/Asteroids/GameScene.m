//
//  GameScene.m
//  Asteroids
//
//  Created by Franklin Yu on 2016/2/17.
//  Copyright (c) 2016年 Franklin Yu. All rights reserved.
//

#import "GameScene.h"
#import "Rock.h"
#import "GameOverScene.h"
#import "SharedConstants.h"
#define kNumLasers      5
NSInteger player_score;

static CGPoint foldPosition(CGPoint position, CGSize size) {
	// fold the `position` into the area specified by `size`
	if (position.x < 0) {
		position.x += size.width;
	} else if (position.x > size.width) {
		position.x -= size.width;
	}
	if (position.y < 0) {
		position.y += size.height;
	} else if (position.y > size.height) {
		position.y -= size.height;
	}
	return position;
}

static CGPoint randomCornerPoint(CGSize size) {
	CGSize corner = CGSizeMake(size.width / 3, size.height / 3);
	CGPoint position;
	position.x = drand48() * corner.width * 2 - corner.width;
	position.y = drand48() * corner.height * 2 - corner.height;
	return foldPosition(position, size);
}

@implementation GameScene{
	SKSpriteNode *_ship;
	NSMutableSet<Rock *> *_rocks;
	NSMutableArray *_shipLasers;
	int _nextShipLaser;
}

-(id)initWithSize:(CGSize)size {
	if (self = [super initWithSize:size]) {
		
		player_score = 0; //initializing score as zero
		
		self.backgroundColor = [SKColor blackColor];
		[self addShip];

		//rock
		self.size = size;
		const int rockCount = 3;
		_rocks = [NSMutableSet setWithCapacity:rockCount];
		for (int i = 0; i < rockCount; i++) {
			Rock *rock = [Rock rockWithPosition:randomCornerPoint(size)];
			[_rocks addObject:rock];
			[self addChild:rock];
			rock.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:rock.radius];
			rock.physicsBody.dynamic = YES;
			rock.physicsBody.categoryBitMask = obstacleCategory;
			rock.physicsBody.contactTestBitMask = shipCategory;
		}

		//shooting
		for (SKSpriteNode *laser in _shipLasers) {
			laser.hidden = YES;
		}

		_shipLasers = [[NSMutableArray alloc] initWithCapacity:kNumLasers];
		for (int i = 0; i < kNumLasers; ++i) {
			SKSpriteNode *shipLaser = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
			shipLaser.hidden = YES;
			shipLaser.size = CGSizeMake(20,20);
			shipLaser.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
			shipLaser.physicsBody.categoryBitMask = projectileCategory;
			shipLaser.physicsBody.contactTestBitMask = obstacleCategory;
			[_shipLasers addObject:shipLaser];
			[self addChild:shipLaser];
		}
		//Making self delegate of physics World sets the scene as the delegate to be notified when two physics bodies collide
		self.physicsWorld.gravity = CGVectorMake(0,0);
		self.physicsWorld.contactDelegate = self;
		
		//load explosions
		SKTextureAtlas *explosionAtlas = [SKTextureAtlas atlasNamed:@"EXPLOSION"];
		NSArray *textureNames = [explosionAtlas textureNames];
		_explosionTextures = [NSMutableArray new];
		for (NSString *name in textureNames) {
			SKTexture *texture = [explosionAtlas textureNamed:name];
			[_explosionTextures addObject:texture];
			
			//score
			NSString * playerscoremsg = [NSString stringWithFormat:@"Score:"];
			
			SKLabelNode *playerscore = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
			playerscore.text = playerscoremsg;
			playerscore.fontColor = [SKColor whiteColor];
			playerscore.position = CGPointMake(self.size.width/2, 370);
			playerscore.name = @"Player Score";
			[playerscore setScale:.5];
			[self addChild:playerscore];
			
			_scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
			_scoreLabel.fontSize = 40;
			_scoreLabel.fontColor = [SKColor whiteColor];
			_scoreLabel.position = CGPointMake(self.size.width/2, 330);
			[self addChild:_scoreLabel];
		}
	}
	return self;
}

-(void)addShip
{
	//initalizing spaceship node
	_ship = [SKSpriteNode spriteNodeWithImageNamed:@"ShipTriangle"];
	_ship.size = CGSizeMake(300, 300);
	[_ship setScale:0.15]; // size of spaceship
	_ship.zRotation = - M_PI / 2;

	//Adding SpriteKit physicsBody for collision detection
	_ship.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_ship.size];
	_ship.physicsBody.categoryBitMask = shipCategory;
	_ship.physicsBody.dynamic = YES;
	_ship.physicsBody.contactTestBitMask = obstacleCategory;
	_ship.physicsBody.collisionBitMask = 0;
	_ship.name = @"ship";
	_ship.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)); //restrict objects from moving outside the rectangular screen

	[self addChild:_ship];
}

-(void)rock:(SKSpriteNode *)rock didCollideWithShip:(SKSpriteNode *)Ship {
	
	[_ship removeFromParent];
	[rock removeFromParent];
	
	
	double delayInSeconds = 1.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

	SKTransition *reveal = [SKTransition crossFadeWithDuration:3.5];
	SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
	[self.view presentScene:gameOverScene transition: reveal];
});
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
	SKPhysicsBody *firstBody, *secondBody;
 
	if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
	{
		firstBody = contact.bodyA;
		secondBody = contact.bodyB;
	}
	else
	{
		firstBody = contact.bodyB;
		secondBody = contact.bodyA;
	}
 
	if ((firstBody.categoryBitMask & shipCategory) &&
		(secondBody.categoryBitMask & obstacleCategory))
	{
		//add explosion
		SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:[_explosionTextures objectAtIndex:0]];
		explosion.zPosition = 1;
		explosion.scale = 0.6;
		explosion.position = contact.bodyA.node.position;
		
		[self addChild:explosion];
		
		SKAction *explosionAction = [SKAction animateWithTextures:_explosionTextures timePerFrame:0.07];
		SKAction *remove = [SKAction removeFromParent];
		[explosion runAction:[SKAction sequence:@[explosionAction,remove]]];
		[self rock:(SKSpriteNode *)secondBody.node didCollideWithShip:(SKSpriteNode *)firstBody.node];
	}

	if (firstBody.categoryBitMask == obstacleCategory && secondBody.categoryBitMask == projectileCategory && !secondBody.node.hidden) {
		secondBody.node.hidden = YES;
		Rock *oldRock = (Rock *)firstBody.node;
		Rock *newRock1 = [oldRock newSubrockWithNormal:contact.contactNormal inDirection:1];
		Rock *newRock2 = [oldRock newSubrockWithNormal:contact.contactNormal inDirection:-1];
		[oldRock removeFromParent];
		if (newRock1 && newRock2) {
			[_rocks addObject:newRock1];
			[_rocks addObject:newRock2];
			[self addChild:newRock1];
			[self addChild:newRock2];
			player_score = player_score + 1;
			[self printScore];
		}
	}
}

- (void)printScore
{
	NSString *text = [NSString stringWithFormat:@"%ld",(long)player_score];
	self.scoreLabel.text = text;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	CGPoint location = [[touches anyObject] locationInNode:self];
	SKAction *move = [SKAction moveTo:location duration:1.0f];
	[_ship runAction:move];

	double angle = atan2(location.y-_ship.position.y,location.x-_ship.position.x);
	[_ship runAction:[SKAction rotateToAngle:angle duration:.1]];

	SKSpriteNode *shipLaser = [_shipLasers objectAtIndex:_nextShipLaser];
	_nextShipLaser++;
	if (_nextShipLaser >= _shipLasers.count) {
		_nextShipLaser = 0;
	}

	shipLaser.position = CGPointMake(_ship.position.x+shipLaser.size.width/2,_ship.position.y+0);
	shipLaser.hidden = NO;
	[shipLaser removeAllActions];

	SKAction *laserMoveAction = [SKAction moveByX:500*cosf(angle) y:500*sinf(angle) duration:0.5];
	SKAction *laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
		shipLaser.hidden = YES;
	}];

	SKAction *moveLaserActionWithDone = [SKAction sequence:@[laserMoveAction,laserDoneAction]];
	[shipLaser runAction:moveLaserActionWithDone withKey:@"laserFired"];
}

-(void)update:(CFTimeInterval)currentTime {
	/* Called before each frame is rendered */
	for (Rock *rock in _rocks) {
		rock.position = foldPosition(rock.position, self.size);
	}
}

@end
