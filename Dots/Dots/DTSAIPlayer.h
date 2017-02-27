@import UIKit;

#import "DTSTypes.h"
#import "DTSAIPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@class DTSGame;
@interface DTSAIPlayer : NSObject

#pragma mark - Making Moves on a Board
/*!
 Returns the recommended move for the given game based on the set difficulty
 level.

 \param level The difficulty level being played on.
 \param game The game to make a move in. Must not be nil.
 \returns The edge to play.
 */
+ (DTSEdge)recommendedMoveForDifficultyLevel:(NSInteger)level inGame:(DTSGame *)game;

@end

NS_ASSUME_NONNULL_END
