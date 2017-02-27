//
//  CaptiveViewController.h
//  P07-The Captives
//
//  Created by Tanmay Kale on 4/5/16.
//  Copyright © 2016 Jigar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaptiveViewController : UIViewController
{
    float dx,dy;
}

@property (nonatomic, strong) NSMutableArray *bricks;
@property (nonatomic,strong) UIImageView *title1;
@property (nonatomic,strong) UILabel *ScoreLabel;
@property (nonatomic,strong) UILabel *ScoreName;
@property (strong, nonatomic) IBOutlet UIButton *HomeButton;

@end
