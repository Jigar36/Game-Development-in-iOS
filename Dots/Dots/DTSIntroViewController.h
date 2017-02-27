@import UIKit;
#import "DTSGameViewController.h"
#import "Dots-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface DTSIntroViewController : UIViewController

#pragma mark - Properties
//! The game view controller that is presented when the user selects a game.
@property (readonly, nullable) DTSGameViewController *gameController;

/*!
 The toggle that allows a user to select between playing against the AI or
 another player.
 */
@property (nullable) IBOutlet BetterSegmentedControl *multiplayerToggle;

#pragma mark - Actions
/*!
 Selects the board size to play and starts a new game with that size.
 */
- (IBAction)playGame:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
