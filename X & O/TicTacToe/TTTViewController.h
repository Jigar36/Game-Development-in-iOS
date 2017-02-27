//
//  TTTViewController.h
//  TicTacToe
//
//  Created by Jigar Panchal on 4/10/16.
//  Copyright © 2016 Jigar. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "TTTBoard.h"

@interface TTTViewController : UIViewController <TTTBoardDelegate>

@property (weak, nonatomic) IBOutlet UIButton *button0;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;
@property (weak, nonatomic) IBOutlet UIButton *button5;
@property (weak, nonatomic) IBOutlet UIButton *button6;
@property (weak, nonatomic) IBOutlet UIButton *button7;
@property (weak, nonatomic) IBOutlet UIButton *button8;

@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *oButton;
@property (weak, nonatomic) IBOutlet UIButton *xButton;

- (IBAction)gridButtonPressed:(id)sender;
- (IBAction)resetButtonPressed:(id)sender;
- (IBAction)oButtonPressed:(id)sender;
- (IBAction)xButtonPressed:(id)sender;


@end
