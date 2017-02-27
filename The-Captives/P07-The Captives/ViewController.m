//
//  ViewController.m
//  P07-The Captives
//
//  Created by Tanmay Kale on 4/5/16.
//  Copyright © 2016 Jigar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    
    //adding image to the main screen
    _title1 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/4-50, screenHeight/6-50, screenWidth-100, 100)];
    _title1.image=[UIImage imageNamed:@"header.png"];
    [self.view addSubview: _title1];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
