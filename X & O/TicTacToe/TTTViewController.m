//
//  TTTViewController.m
//  TicTacToe
//
//
//  Created by Jigar Panchal on 4/10/16.
//  Copyright © 2016 Jigar. All rights reserved.
//


#import "TTTViewController.h"
#import "TTTBoard.h"
#import "TTTComputer.h"

@interface TTTViewController ()

@property (nonatomic, strong, readwrite) TTTBoard *board;
@property (nonatomic, strong, readwrite) NSMutableArray* buttons;
@property (nonatomic, strong, readwrite) TTTComputer *computer;
@property (nonatomic, assign, readwrite) BOOL gameStarted;
@property (nonatomic, assign, readwrite) TTTBoardMarker humanMarker;

@end

@implementation TTTViewController


#pragma mark - View Lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.board = [[TTTBoard alloc] init];
    self.board.delegate = self;
    
    self.buttons = [NSMutableArray arrayWithObjects:self.button0, self.button1, self.button2,
                    self.button3, self.button4, self.button5, self.button6, self.button7, self.button8, nil];
    
    self.computer = [[TTTComputer alloc] init];
   // [self.titleLabel setFont:[UIFont boldSystemFontOfSize:40]];
     [self.titleLabel setFont:[UIFont fontWithName:@"Chalkdustr" size:40]];
    
    [self.resetButton setTitle:@"Reset Game" forState:UIControlStateNormal];
    
    
}

#pragma mark - User Actions

- (IBAction) gridButtonPressed:(id)sender {
    // Reset the title label in case the user picked X
    [self.titleLabel setText:@"X & O"];
    
    NSInteger index = [sender tag];
    
    BOOL playerDidMove = [self.board moveMarker:self.humanMarker toLocation:index];
    
    if (!playerDidMove) {
        return;
    }
    
    
    
    [self performComputerMoveWithFeedback:NO];
}

- (IBAction) resetButtonPressed:(id)sender {
    
    if (!self.gameStarted) {
        self.gameStarted = YES;
        [self.resetButton setTitle:@"Reset Game" forState:UIControlStateNormal];
    }
    
    [self.titleLabel setText:@"X & O"];
     [self.titleLabel setFont:[UIFont fontWithName:@"Chalkdustr" size:40]];
    [self.board resetGrid];
    
    [self.oButton setHidden:NO];
    [self.xButton setHidden:NO];
}


- (IBAction)oButtonPressed:(id)sender {
    [self.oButton setHidden:YES];
    [self.xButton setHidden:YES];
    
    self.humanMarker = TTTBoardMarkerO;
    
    // Computer goes first
    // Calculating the first move is the most expensive so the feedback option displays "Computer Thinking" text to the user
    [self performComputerMoveWithFeedback:YES];
}

- (IBAction)xButtonPressed:(id)sender {
    [self.oButton setHidden:YES];
    [self.xButton setHidden:YES];
    
    [self setButtonsEnabled:YES];
    
    self.humanMarker = TTTBoardMarkerX;
    [self.titleLabel setText:@"Your Move"];
}

#pragma mark - AI / Game Completion

- (void) performComputerMoveWithFeedback:(BOOL)feedback {
    [self.titleLabel setText:@"Computer Thinking..."];
    if (feedback) {
        [self.titleLabel setText:@"Computer Thinking..."];
        
    }
   
    
    TTTBoardMarker computerMarker = [self.board opponentForMarker:self.humanMarker];

    TTTVoidBlock calculateComputerMove = ^{
        
        // This callback update UI elements on the main thread and checks the game board after the computer's move
        TTTIntegerBlock performMove = ^(NSInteger move){
            [self.board moveMarker:computerMarker toLocation:move];
            [self.titleLabel setText:@"X & O"];
            [self setButtonsEnabled:YES];
            [self isGameComplete];
        };
        
        [self.computer moveMarker:computerMarker onBoard:self.board withCallBack:performMove];
    };
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, calculateComputerMove);
}

- (void) isGameComplete {
    if ([self.board isGameComplete]) {
        TTTBoardMarker winningMarker = self.board.winner;
        NSString *winner = [self.board stringForMarker:winningMarker];
        
        NSString *titleText;
        if ([winner isEqualToString:@""]) {
            titleText = @"Draw";
        } else {
            titleText = [NSString stringWithFormat:@"%@ wins", winner];
        }
        
        [self.titleLabel setText:titleText];
        [self setButtonsEnabled:NO];
        for (int i = 0; i < 9; i++) {
            [[self.buttons objectAtIndex:i] setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    
    [self.resetButton setHidden:NO];
}

#pragma mark - TTTBoardDelegate Methods

- (void) didUpdateGridAtIndex:(NSInteger)index withMarker:(NSString*)marker {
    UIButton *button = [self.buttons objectAtIndex:index];
   // if ([marker  isEqual: @"X"]) {
    
  //  }
    [button setTitle:marker forState:UIControlStateNormal];
    
    
   
    
    
    if([marker isEqualToString:@"X"])
    {
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        button.layer.shadowColor = [UIColor redColor].CGColor;
        button.layer.shadowRadius = 10.0f;
        button.layer.shadowOpacity = 1.0f;
        button.layer.shadowOffset = CGSizeZero;
        
        
        [UIView animateWithDuration:0.7f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction  animations:^{
            
            [UIView setAnimationRepeatCount:150000];
            
            button.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
            
            
        } completion:^(BOOL finished) {
            
            button.layer.shadowRadius = 0.0f;
            button.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }];
    }
    if([marker isEqualToString:@"O"])
    {
        [button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        button.layer.shadowColor = [UIColor yellowColor].CGColor;
        button.layer.shadowRadius = 10.0f;
        button.layer.shadowOpacity = 1.0f;
        button.layer.shadowOffset = CGSizeZero;
        
        
        [UIView animateWithDuration:0.7f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction  animations:^{
            
            [UIView setAnimationRepeatCount:150000];
            
            button.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
            
            
        } completion:^(BOOL finished) {
            
            button.layer.shadowRadius = 0.0f;
            button.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }];
    }
}

#pragma mark - Helper Methods

- (void) setButtonsEnabled:(BOOL)enabled {
    for (UIButton *button in self.buttons) {
        [button setEnabled:enabled];
    }
}

@end
