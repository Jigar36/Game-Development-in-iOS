//
//  TwoPlayerViewController.m
//  Duet
//
//  Created by Jigar Panchal on 5/14/16.
//  Copyright © 2016 Jigar Panchal. All rights reserved.
//

#import "TwoPlayerViewController.h"
#import "TwoPlayerScene.h"


@implementation TwoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO; //set to YES if you do want to see frame rate on screen
    skView.showsNodeCount = NO; // set to YES if you do want to see node count on scren
    
    // Create and configure the scene.
    CGFloat w = skView.bounds.size.width;
    CGFloat h = skView.bounds.size.height;
    CGSize sceneSize = CGSizeMake(w, h);
    //to make sure that scene size is made for landscape mode :)
    if (h > w) {
        sceneSize = CGSizeMake(h, w);
    }
    
    SKScene * scene = [TwoPlayerScene sceneWithSize:sceneSize];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
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
