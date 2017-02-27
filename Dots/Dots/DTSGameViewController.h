@import UIKit;
#import "DTSGameDelegate.h"
#import "DTSGameViewDelegate.h"
#import "Dots-Swift.h"

@class DTSGame;
@class DTSGameView;
@interface DTSGameViewController : UIViewController <DTSGameDelegate, DTSGameViewDelegate>

#pragma mark - Properties
//! The current game being played.
@property (readonly) DTSGame *game;

//! The view which displays the game being played.
@property (readonly) DTSGameView *gameView;

//! A container view created in IB to contain the game view above.
@property IBOutlet UIView *gameContainerView;

//! The label showing player one's score.
@property IBOutlet UILabel *player1ScoreLabel;

//! The labels encompassing player one's data.
@property IBOutletCollection(UILabel) NSArray<UILabel *> *player1Labels;

//! The label showing player two's score.
@property IBOutlet UILabel *player2ScoreLabel;

//! The labels encompassing player two's data.
@property IBOutletCollection(UILabel) NSArray<UILabel *> *player2Labels;

#pragma mark - Setting up a Game
/*!
 Sets up a new game to be played with the given board size.
 
 This method is intended to be called in \c -prepareForSegue: in a source view
 controller to set up the game prior to display.
 
 \param dimensions The board size to use. Must be at least 2×2.
 \param flag Whether to set up a game AI or not.
 \throws \c NSInvalidArgumentException when the given board size is not valid.
 */
- (void)setUpGameWithBoardDimensions:(CGSize)dimensions playingAgainstAI:(BOOL)flag;


@end
