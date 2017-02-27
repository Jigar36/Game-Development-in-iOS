//
//  GameViewController.h
//  p06-Spikester
//
//  Created by Tejas Nadkarni on 15/03/16.
//  Copyright © 2016 tkale1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>


@interface GameViewController : UIViewController
{
    SystemSoundID jumpSound;
    SystemSoundID walltouchSound;
    SystemSoundID gameoverSound;
}
@property (strong, nonatomic) IBOutlet UILabel *FinalScore;
@property (strong, nonatomic) IBOutlet UILabel *trofyCount;
@property (strong, nonatomic) IBOutlet UIImageView *trophyImageView;
@property (strong, nonatomic) IBOutlet UIImageView *trophyImageView1;

@property (strong, nonatomic) IBOutlet UIImageView *bear;
@property (strong, nonatomic) IBOutlet UIImageView *trophy;
@property (strong, nonatomic) IBOutlet UIView *score;

@property (strong, nonatomic) IBOutlet UIView *gameOver;
@property (strong, nonatomic) IBOutlet UIButton *goHome;

@property (strong, nonatomic) IBOutlet UIImageView *bearcatview;

@property (nonatomic, strong) NSMutableArray * upspikes;
@property (nonatomic, strong) NSMutableArray * downspikes;
@property (nonatomic, strong) NSMutableArray * leftspikes;
@property (nonatomic, strong) NSMutableArray * rightspikes;

//@property (strong, nonatomic) IBOutlet UIView *GameOverView;
@property (nonatomic, strong) NSTimer *timer;
@end


