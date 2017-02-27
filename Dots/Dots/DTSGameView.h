@import UIKit;
#import "DTSGameDelegate.h"
#import "DTSGameViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class DTSGame;
@interface DTSGameView : UIView <DTSGameDelegate>

#pragma mark - Properties
//! The game model being displayed in the view.
@property (readonly) DTSGame *game;

//! A delegate object informed when moves are performed.
@property (nullable) id<DTSGameViewDelegate> delegate;

#pragma mark - Initialization
/*!
 Creates a new game view with the given frame and game model.
 
 \param frame The frame to give the view.
 \param game The game to display in the view.
 \returns A new game view object.
 */
+ (instancetype)gameViewWithFrame:(CGRect)frame game:(DTSGame *)game;

/*!
 Initializes the receiver with the given frame and game model.

 \param frame The frame to give the view.
 \param game The game to display in the view.
 \returns An initialized game view.
 */
- (instancetype)initWithFrame:(CGRect)frame game:(DTSGame *)game;

#pragma mark - Making Moves on the Board
/*!
 Plays the given edge for the current player with the given delay afterwards.
 
 \param edge The edge to play.
 \param delay The amount of time to wait after playing the edge, before
              informing the view delegate of the move.
 \returns Whether the current player gets to keep playing after this move.
 */
- (BOOL)playEdge:(DTSEdge)edge withDelay:(NSTimeInterval)delay;

@end

NS_ASSUME_NONNULL_END
