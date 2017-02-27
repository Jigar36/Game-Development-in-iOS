//
//  GameScreen.h
//  BreakOut
//
//  Created by Jigs on 2/13/16.
//  Copyright © 2016 Jigar Panchal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
@interface GameScreen : UIView
{
    float dx, dy;  // Ball motion
}
@property (nonatomic, strong) UIView *paddle;
@property (nonatomic, strong) UIView *ball;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIView *brick1;
@property (nonatomic, strong) UIView *brick2;
@property (nonatomic, strong) UIView *brick3;
@property (nonatomic, strong) UIView *brick4;
@property (nonatomic, strong) UIView *brick5;

@property (nonatomic, strong) UIView *brickGameOver;
@property (nonatomic, strong) NSMutableArray *bricks;
@property (weak, nonatomic) IBOutlet UILabel *Score;
extern int ScoreCount;

-(void)createPlayField;

@end