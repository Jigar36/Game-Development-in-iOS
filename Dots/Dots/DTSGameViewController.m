#import "DTSGameViewController.h"
#import "DTSGame.h"
#import "DTSGameView.h"
#import "DTSAIPlayer.h"
#import "UIColor+DTSColors.h"
#import "SCLAlertView.h"
#import "Dots-Swift.h"

#pragma mark Private Interface
@interface DTSGameViewController ()

#pragma mark - Private Properties
//! The dimensions of the game being presented.
@property CGSize dimensions;

//! A writable version of the public property.
@property DTSGame *game;

//! A writable version of the public property.
@property DTSGameView *gameView;

//! Whether the user is playing the AI or not.
@property BOOL playingAI;

//! Stores the score of player 1.
@property NSInteger player1Score;

//! Stores the score of player 2.
@property NSInteger player2Score;

//! The segmented control that allows the user to set AI difficulty.
@property BetterSegmentedControl *difficultyToggle;

//! The view that displays confetti when a player wins.
@property SAConfettiView *confettiView;

@end

#pragma mark -
@implementation DTSGameViewController

#pragma mark - Initialization
- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (!(self = [super initWithCoder:decoder])) {
        return nil;
    }

    // Observe changes in scores so we can auto update labels.
    [self addObserver:self forKeyPath:@"player1Score" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"player2Score" options:NSKeyValueObservingOptionNew context:NULL];

    return self;
}

#pragma mark - Deallocation
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"player1Score"];
    [self removeObserver:self forKeyPath:@"player2Score"];
}

#pragma mark - KVO Observation
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"player1Score"]) {
        NSNumber *score = change[NSKeyValueChangeNewKey];
        self.player1ScoreLabel.text = [score stringValue];
    } else if ([keyPath isEqualToString:@"player2Score"]) {
        NSNumber *score = change[NSKeyValueChangeNewKey];
        self.player2ScoreLabel.text = [score stringValue];
    }
}

#pragma mark - Setting up a Game
- (void)setUpGameWithBoardDimensions:(CGSize)dimensions playingAgainstAI:(BOOL)flag
{
    self.dimensions = dimensions;
    self.playingAI = flag;
}

#pragma mark - View Life Cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    if (self.playingAI) {
        self.difficultyToggle = [[BetterSegmentedControl alloc] initWithTitles:@[@"Trivial", @"Easy", @"Medium", @"Difficult"]];
        self.difficultyToggle.bounds = CGRectMake(0, 0, 300, 30);
        self.difficultyToggle.cornerRadius = 4;
        self.difficultyToggle.titleColor = [UIColor dts_textColor];
        self.difficultyToggle.indicatorViewBackgroundColor = [UIColor dts_neutralColor];
        self.difficultyToggle.titleFont = [UIFont fontWithName:@"Avenir-Heavy" size:14.0];
        [self.difficultyToggle setIndex:1 animated:NO error:nil];

        self.navigationController.toolbarHidden = NO;
        self.toolbarItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
                              [[UIBarButtonItem alloc] initWithCustomView:self.difficultyToggle],
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL]];

    }

    for (UILabel *label in self.player1Labels) {
        label.textColor = [UIColor dts_player1Color];
    }

    self.game = [DTSGame gameWithBoardDimensions:self.dimensions];
    self.game.delegate = self;

    self.gameView = [DTSGameView gameViewWithFrame:self.gameContainerView.bounds game:self.game];
    self.gameView.translatesAutoresizingMaskIntoConstraints = NO;
    self.gameView.backgroundColor = [UIColor clearColor];
    self.gameView.delegate = self;

    [self.gameContainerView addSubview:self.gameView];
    [self.gameView.widthAnchor constraintEqualToAnchor:self.gameContainerView.widthAnchor].active = YES;
    [self.gameView.heightAnchor constraintEqualToAnchor:self.gameContainerView.heightAnchor].active = YES;
    [self.gameView.centerXAnchor constraintEqualToAnchor:self.gameContainerView.centerXAnchor].active = YES;
    [self.gameView.centerYAnchor constraintEqualToAnchor:self.gameContainerView.centerYAnchor].active = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];

    [self.confettiView stopConfetti];
    [self.confettiView removeFromSuperview];
}

#pragma mark - DTSGameDelegate Methods
- (void)player:(NSInteger)player didCaptureBoxAtLocation:(DTSLocation)location
{
    if (player == 1) {
        self.player1Score += 1;
    } else {
        self.player2Score += 1;
    }

    // Let the game view know so it can fill the box in.
    [self.gameView player:player didCaptureBoxAtLocation:location];

    NSInteger totalScore = (NSInteger)(self.game.dimensions.width * self.game.dimensions.height);
    if (self.player1Score + self.player2Score == totalScore) {
        self.gameView.userInteractionEnabled = NO;

        SCLAlertViewBuilder *builder = [SCLAlertViewBuilder new];
        SCLAlertViewShowBuilder *showBuilder = [SCLAlertViewShowBuilder new];

        if (self.player1Score == self.player2Score) {
            showBuilder.style(Info).title(@"You Tied").subTitle(@"Neither player has won.").closeButtonTitle(@"Done");
        } else {
            BOOL victory = ((self.player1Score > self.player2Score) && (self.playingAI || player == 1)) ||
                           ((self.player1Score < self.player2Score) && (!self.playingAI && player == 2));
            if (victory) {
                showBuilder.style(Success).title(@"You Won");
                if (self.playingAI) {
                    showBuilder.subTitle(@"You beat the AI!");
                } else {
                    NSInteger oppositePlayer = player == 1 ? 2 : 1;
                    showBuilder.subTitle([NSString stringWithFormat:@"You beat player %d!", (int)oppositePlayer]);
                }

                builder.addButtonWithActionBlock(@"Done", ^{
                    self.confettiView = [[SAConfettiView alloc] initWithFrame:self.view.frame];
                    [self.view addSubview:self.confettiView];
                    [self.confettiView startConfetti];
                });
            } else {
                showBuilder.style(Error).title(@"You Lost").closeButtonTitle(@"Done");
                if (self.playingAI) {
                    showBuilder.subTitle(@"The AI has won.");
                } else {
                    NSInteger oppositePlayer = player == 1 ? 2 : 1;
                    showBuilder.subTitle([NSString stringWithFormat:@"Player %d wins.", (int)oppositePlayer]);
                }
            }
        }

        // Wait for half a second before showing the alert.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [showBuilder showAlertView:builder.alertView onViewController:self];
        });
    }
}

#pragma mark - DTSGameViewDelegate Methods
static inline void DTSTransitionLabelTextColorToColor(UILabel *label, UIColor *color, NSTimeInterval duration)
{
    [UIView transitionWithView:label duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        label.textColor = color;
    } completion:^(BOOL finished) {}];
}

- (void)player:(NSInteger)player didCompleteTurnInView:(DTSGameView *)view
{
    NSTimeInterval duration = self.playingAI ? 1.0 / (self.difficultyToggle.index + 1) : 0.5;

    self.gameView.userInteractionEnabled = NO;
    [UIView animateWithDuration:duration animations:^{
        if (player == 1) {
            for (UILabel *label in self.player1Labels) {
                DTSTransitionLabelTextColorToColor(label, [UIColor dts_textColor], duration);
            }

            for (UILabel *label in self.player2Labels) {
                DTSTransitionLabelTextColorToColor(label, [UIColor dts_player2Color], duration);
            }
        } else {
            for (UILabel *label in self.player2Labels) {
                DTSTransitionLabelTextColorToColor(label, [UIColor dts_textColor], duration);
            }

            for (UILabel *label in self.player1Labels) {
                DTSTransitionLabelTextColorToColor(label, [UIColor dts_player1Color], duration);
            }
        }
    } completion:^(BOOL finished) {
        if (player == 1 && self.playingAI) {
            NSInteger totalScore = (NSInteger)(self.game.dimensions.width * self.game.dimensions.height);
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                __block BOOL canKeepPlaying = YES;
                while (canKeepPlaying) {
                    DTSEdge edge = [DTSAIPlayer recommendedMoveForDifficultyLevel:(NSInteger)self.difficultyToggle.index inGame:self.game];

                    dispatch_sync(dispatch_get_main_queue(), ^{
                        canKeepPlaying = [self.gameView playEdge:edge withDelay:duration] && (self.player1Score + self.player2Score) < totalScore;
                    });
                }

                [NSThread sleepForTimeInterval:duration];
            });
        } else {
            // The user can play again.
            self.gameView.userInteractionEnabled = YES;
        }
    }];
}

@end
