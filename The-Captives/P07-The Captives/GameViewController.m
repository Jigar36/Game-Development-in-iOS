//
//  GameViewController.m
//  P07-The Captives
//
//  Created by Tanmay Kale on 4/5/16.
//  Copyright © 2016 Jigar. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

@end

@implementation GameViewController
@synthesize bricks;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    
    
    bricks = [NSMutableArray array];
    
    int y = 80,x=20;
    for(int k=0; k<7; k ++){
        x=10;
        for (int i=0;i<10;i++){
            UILabel *brick;
            // int x = (screenWidth/10)*i;
            
            brick= [[UILabel alloc] initWithFrame:CGRectMake(x, y, screenWidth/10, 15)];
            [brick setBackgroundColor:[UIColor blueColor];
            brick.layer.borderColor = [UIColor whiteColor].CGColor;
            brick.layer.borderWidth = 2;
            [self.view addSubview:brick];
            [bricks addObject:brick];
            x=x+39;
        }
        y = y + 15;
    }
    
    dx = 10;
    dy = 10;
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
