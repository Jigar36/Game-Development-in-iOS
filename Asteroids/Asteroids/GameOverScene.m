//
//  GameOverScene.m
//  Asteroids
//
//  Created by Jigs on 2/22/16.
//  Copyright © 2016 Franklin Yu. All rights reserved.
//
#import "GameOverScene.h"
#import "GameScene.h"

@implementation GameOverScene
-(id)initWithSize:(CGSize)size {
	if (self = [super initWithSize:size]) {
		self.backgroundColor = [SKColor blackColor];
		NSString * message;
		message = @"Game Over";
		SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
		label.text = message;
		label.fontSize = 40;
		label.fontColor = [SKColor whiteColor];
		label.position = CGPointMake(self.size.width/2, self.size.height/2);
		[self addChild:label];
		
		NSString * retrymessage;
		retrymessage = @"Replay Game";
		SKLabelNode *retryButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
		retryButton.text = retrymessage;
		retryButton.fontColor = [SKColor whiteColor];
		retryButton.position = CGPointMake(self.size.width/2, 50);
		retryButton.name = @"retry";
		[self addChild:retryButton];
		
	}
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode:self];
	SKNode *node = [self nodeAtPoint:location];
	
	if ([node.name isEqualToString:@"retry"]) {
		
		SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
		GameScene * scene = [GameScene sceneWithSize:self.view.bounds.size];
		scene.scaleMode = SKSceneScaleModeAspectFill;
		[self.view presentScene:scene transition: reveal];
		
	}
}
@end