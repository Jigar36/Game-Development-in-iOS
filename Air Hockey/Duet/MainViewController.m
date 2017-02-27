//
//  MainViewController.m
//  Duet
//
//  Created by Jigar Panchal on 5/14/16.
//  Copyright © 2016 Jigar Panchal. All rights reserved.
//

#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface MainViewController ()

@end

@implementation MainViewController
@synthesize SinglePlayer, TwoPlayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidLoad) name:@"NOTIFICATIONNAME" object:nil];

    
    SinglePlayer.layer.cornerRadius = 5.0;
    SinglePlayer.layer.shadowOpacity = 3.0;
    SinglePlayer.alpha = 0.9;
    
    [SinglePlayer setBackgroundColor:[UIColor orangeColor]];
    
    
    
    TwoPlayer.layer.cornerRadius = 5.0;
    TwoPlayer.layer.shadowOpacity = 3.0;
    TwoPlayer.alpha = 0.9;
    [TwoPlayer setBackgroundColor:[UIColor colorWithRed:255/255 green:187/255 blue:0/255 alpha:1.0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
