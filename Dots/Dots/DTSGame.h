@import UIKit;
#import "DTSGameDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 Represents the game of Dots, including the boxes, edges, and player scores.
 */
@interface DTSGame : NSObject

#pragma mark - Properties
//! The game's dimensions.
@property (readonly) CGSize dimensions;

/*!
 The delegate the game informs moves of.
 */
@property (nullable) id<DTSGameDelegate> delegate;

/*!
 The horizontal edges that make up the game.

 A value of 0 implies that an edge has not yet been played; 1 implies that it
 was played by player 1, and 2 by player 2.
 */
@property (readonly) NSMutableArray<NSMutableArray<NSNumber *> *> *horizontalEdges;

/*!
 The vertical edges that make up the game.

 A value of 0 implies that an edge has not yet been played; 1 implies that it
 was played by player 1, and 2 by player 2.
 */
@property (readonly) NSMutableArray<NSMutableArray<NSNumber *> *> *verticalEdges;

/*!
 The grid of boxes that make up the game.

 A value of 0 implies that a box has not yet been filled; 1 implies that it was
 filled by player 1, and 2 by player 2.
 */
@property (readonly) NSMutableArray<NSMutableArray<NSNumber *> *> *boxes;

//! The player currently making a move. Alternates between 1 and 2.
@property (readonly) NSInteger currentPlayer;

#pragma mark - Initialization
/*!
 Creates a new game with the given size, corresponding to the number of dots in
 either dimension.
 
 Given a size of m×n, the board will have (m - 1)×(n - 1) edges and boxes.
 
 \param dimensions The dimensions of the board, corresponding to the number of
                   drawn dots. Must be at least 2×2.
 \returns A newly created game with the given dimension.
 \throws NSInvalidArgumentException on invalid size.
 */
+ (instancetype)gameWithBoardDimensions:(CGSize)size;

/*!
 Initializes the receiver with the given size, corresponding to the number of
 dots in either dimension.

 Given a size of m×n, the board will have (m - 1)×(n - 1) edges and boxes.

 \param dimensions The dimensions of the board, corresponding to the number of
                   drawn dots. Must be at least 2×2.
 \returns A newly created game with the given dimension.
 \throws NSInvalidArgumentException on invalid size.
 */
- (instancetype)initWithBoardDimensions:(CGSize)size;

#pragma mark - Making Moves on a Board
/*!
 Checks if a box is taken by a player
 
 \param location Location of box.
 \returns Whether the box is taken.
 */
- (BOOL)boxIsSurrounded:(DTSLocation)location;

/*!
 Returns whether an edge is valid, and has not yet been played.

 \param edge The edge to look up.
 \returns \c NO if the given edge's location is not within the game grid or the
          edge has already been played; \c YES otherwise.
 */
- (BOOL)canPlayEdge:(DTSEdge)edge;

/*!
 Plays the given edge for the current player.
 
 \param edge The edge to play.
 \returns The player who made the move.
 \throws \c NSInvalidArgumentException if \c -canPlayEdge: returns \c NO for the
         given edge.
 */
- (NSInteger)playEdge:(DTSEdge)edge;

/*!
 Number of edges around the box at a given locaiton.
 
 \param location Location of the box.
 \returns Number of edges around the box.
 */
- (NSUInteger)edgesAroundBox:(DTSLocation)location;

- (BOOL)boxMissingTopEdge:(DTSLocation)location;
- (BOOL)boxMissingBottomEdge:(DTSLocation)location;
- (BOOL)boxMissingRightEdge:(DTSLocation)location;
- (BOOL)boxMissingLeftEdge:(DTSLocation)location;

/*!
 Check if playing an edge would give a point.
 
 \param edge The edge to play.
 \returns Whether playing the edge would net in a point for the player who made the move.
 */
- (BOOL)edgeWouldCapture:(DTSEdge)edge;

/*!
 Returns the number of edges for the box(es) that an edge would affect
 
 \param edge The edge of a box.
 \return Maximum edge count of box(es) that an edge affects
 */
- (NSUInteger)maxNeighboringEdges:(DTSEdge)edge;

@end

NS_ASSUME_NONNULL_END
