//
//  GameScene.h
//  Asteroids
//

//  Copyright (c) 2016年 Franklin Yu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene <SKPhysicsContactDelegate>
@property NSMutableArray *explosionTextures;
@property (nonatomic, strong) SKLabelNode *scoreLabel;
@end
