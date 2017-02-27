//
//  GameViewController.m
//  Duet
//
//  Created by Jigar Panchal on 5/11/16.
//  Copyright (c) 2016 Jigar Panchal. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "DifficultyLevelsViewController.h"

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"MYGlobalVariable = %@",MYGlobalVariable);
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
    
    SKScene * scene = [GameScene sceneWithSize:sceneSize];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
