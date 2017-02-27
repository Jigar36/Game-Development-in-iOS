#import "DTSGame.h"

#pragma mark Private Interface
@interface DTSGame ()

#pragma mark - Private Properties
//! A writable version of the public property.
@property NSInteger currentPlayer;

@end

#pragma mark -
@implementation DTSGame

#pragma mark - Initialization
+ (instancetype)gameWithBoardDimensions:(CGSize)dimensions
{
    return [[self alloc] initWithBoardDimensions:dimensions];
}

- (instancetype)initWithBoardDimensions:(CGSize)dimensions
{
    if (dimensions.width < 2 || dimensions.height < 2) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Invalid game size." userInfo:nil];
    } else if (!(self = [super init])) {
        return nil;
    }

    _dimensions = dimensions;

    NSMutableArray *row = [NSMutableArray array];
    for (NSUInteger i = 0; i < dimensions.width; i += 1) {
        [row addObject:@0];
    }

    _horizontalEdges = [NSMutableArray array];
    for (NSUInteger i = 0; i < dimensions.height + 1; i += 1) {
        [_horizontalEdges addObject:[row mutableCopy]];
    }

    _boxes = [NSMutableArray array];
    for (NSUInteger i = 0; i < dimensions.height; i += 1) {
        [_boxes addObject:[row mutableCopy]];
    }
    
    [row addObject:@0];
    _verticalEdges = [NSMutableArray array];
    for (NSUInteger i = 0; i < dimensions.height; i += 1) {
        [_verticalEdges addObject:[row mutableCopy]];
    }

    _currentPlayer = 1;
    return self;
}

#pragma mark - Making Moves on a Board
- (BOOL)canPlayEdge:(DTSEdge)edge
{
    NSUInteger x = edge.location.x, y = edge.location.y;
    NSArray<NSArray<NSNumber *> *> *array = edge.horizontal ? self.horizontalEdges : self.verticalEdges;

    return y < array.count    && /* array[y] is valid */
           x < array[0].count && /* array[y][x] is valid */
           [array[y][x] isEqualToNumber:@0];
}

- (NSInteger)playEdge:(DTSEdge)edge
{
    if (![self canPlayEdge:edge]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Cannot play at the given location." userInfo:nil];
    }

    NSUInteger x = edge.location.x, y = edge.location.y;
    (edge.horizontal ? self.horizontalEdges : self.verticalEdges)[y][x] = @(self.currentPlayer);

    BOOL boxesCaptured = NO;
    if (edge.horizontal) {
        if (y > 0) {
            // Can check to see if we're the bottom edge to a box captured
            // above.
            boxesCaptured |= [self captureBox:(DTSLocation){x, y - 1}];
        }

        if (y < self.horizontalEdges.count - 1) {
            // Can check to see if we're the top edge to a box captured below.
            boxesCaptured |= [self captureBox:edge.location];
        }
    } else {
        if (x > 0) {
            // Can check to see if we're the right edge to a box captured to the
            // left.
            boxesCaptured |= [self captureBox:(DTSLocation){x - 1, y}];
        }

        if (x < self.verticalEdges[0].count - 1) {
            // Can check to see if we're the left edge to a box captured to the
            // right.
            boxesCaptured |= [self captureBox:edge.location];
        }
    }

    NSInteger player = self.currentPlayer;
    if (!boxesCaptured) {
        // If a player captured boxes, they get to go again; otherwise, it's the
        // next player's turn.
        self.currentPlayer = (player == 1) ? 2 : 1;
    }

    return player;
}

/*!
 Checks if a box is surrounded on all four sides.
 
 \param location The location of the box to check.
 \returns Whether there are four edges around the box.
 */
- (BOOL)boxIsSurrounded:(DTSLocation)location
{
    return [self edgesAroundBox:location] == 4;
}

/*!
 Counts the number of edges that have been played around a box.
 
 \param location The location of the box to check.
 \returns Number of edges surrounding the box.
 */
- (NSUInteger)edgesAroundBox:(DTSLocation)location
{
    NSUInteger x = location.x, y = location.y;
    NSUInteger edges = 0;
    if (![self.verticalEdges[y][x] isEqualToNumber:@0])
        edges += 1;
    if (![self.verticalEdges[y][x + 1] isEqualToNumber:@0])
        edges += 1;
    if (![self.horizontalEdges[y][x] isEqualToNumber:@0])
        edges += 1;
    if (![self.horizontalEdges[y + 1][x] isEqualToNumber:@0])
        edges += 1;
    return edges;
}

- (BOOL)boxMissingTopEdge:(DTSLocation)location
{
    return [self.horizontalEdges[location.y][location.x] isEqualToNumber:@0];
}
- (BOOL)boxMissingBottomEdge:(DTSLocation)location
{
    return [self.horizontalEdges[location.y+1][location.x] isEqualToNumber:@0];
}
- (BOOL)boxMissingRightEdge:(DTSLocation)location
{
    return [self.verticalEdges[location.y][location.x+1] isEqualToNumber:@0];
}
- (BOOL)boxMissingLeftEdge:(DTSLocation)location
{
    return [self.verticalEdges[location.y][location.x] isEqualToNumber:@0];
}

/*!
 Attempts to capture the box at the given location for the current player,
 returning whether the box has been captured.

 \param location The location of the box to attempt to capture.
 \returns Whether the box was successfully captured.
 */
- (BOOL)captureBox:(DTSLocation)location
{
    if ([self boxIsSurrounded:location]) {
        self.boxes[location.y][location.x] = @(self.currentPlayer);
        [self.delegate player:self.currentPlayer didCaptureBoxAtLocation:location];
        return YES;
    }

    return NO;
}

/*!
 Attempts to capture the box at the given location for the current player,
 returning whether the box has been captured.
 
 \param location The location of the box to attempt to capture.
 \returns Whether the box was successfully captured.
 */
- (BOOL)edgeWouldCapture:(DTSEdge)edge
{
    NSUInteger x = edge.location.x, y = edge.location.y;
    
    // Chek top/bottom boxes for possible capture
    if (edge.horizontal) {
        self.horizontalEdges[y][x] = @123;
        if (y > 0) {
            DTSLocation topBoxLocation = {.x = x, .y = y - 1};
            if ([self boxIsSurrounded:(topBoxLocation)]) {
                self.horizontalEdges[y][x] = @0;
                return YES;
            }
        }
        if (y < self.horizontalEdges.count - 1 && [self boxIsSurrounded:(edge.location)]) {
            self.horizontalEdges[y][x] = @0;
            return YES;
        }
        self.horizontalEdges[y][x] = @0;
    }
    // Check left/right boxes for possible capture
    else {
        self.verticalEdges[y][x] = @123;
        if (x > 0) {
            DTSLocation leftBoxLocation = {.x = x - 1, .y = y};
            if ([self boxIsSurrounded:(leftBoxLocation)]) {
                self.verticalEdges[y][x] = @0;
                return YES;
            }
        }
        if (x < self.verticalEdges[0].count - 1 && [self boxIsSurrounded:(edge.location)]) {
            self.verticalEdges[y][x] = @0;
            return YES;
        }
        self.verticalEdges[y][x] = @0;
    }
    return NO;
}

/*!
 Calculates the number of edges that exist on the box(es) that an edge is a part of.
 This is used to find "safe" moves that will not give boxes away to the opponent.
 
 \param edge The edge to use to check neighboring boxes, not counted in result.
 \return Maximum number of edges in neighboring box(es).
 */
- (NSUInteger)maxNeighboringEdges:(DTSEdge)edge
{
    NSUInteger max = 0;
    NSUInteger x = edge.location.x, y = edge.location.y;
    if (edge.horizontal) {
        if (y > 0) {
            DTSLocation topBoxLocation = {.x = x, .y = y - 1};
            max = MAX(max, [self edgesAroundBox:topBoxLocation]);
        }
        if (y < self.horizontalEdges.count - 1) {
            max = MAX(max, [self edgesAroundBox:edge.location]);
        }
    }
    else {
        if (x > 0) {
            DTSLocation leftBoxLocation = {.x = x - 1, .y = y};
            max = MAX(max, [self edgesAroundBox:leftBoxLocation]);
        }
        if (x < self.verticalEdges[0].count - 1) {
            max = MAX(max, [self edgesAroundBox:edge.location]);
        }
    }
    return max;
}

@end
