@import Foundation;

@class DTSGameView;
@protocol DTSGameViewDelegate <NSObject>

/*!
 Informs the delegate that a human player made a move in the given view.
 
 \param view The view the user played in.
 */
- (void)player:(NSInteger)player didCompleteTurnInView:(DTSGameView *)view;

@end
