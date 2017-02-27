@import Foundation;
#import "DTSTypes.h"

@class DTSGame;
@protocol DTSGameDelegate <NSObject>

/*!
 Informs the delegate that a player has successfully captured a box in the game.
 
 \param player The player who made the move.
 \param location The location of the box the player captured.
 */
- (void)player:(NSInteger)player didCaptureBoxAtLocation:(DTSLocation)location;

@end
