#import "DTSGameView.h"
#import "DTSGame.h"
#import "UIColor+DTSColors.h"

#pragma mark Constants
static const CGFloat DTSGameViewDotRadius = 4.0;

#pragma mark - Private Interface
@interface DTSGameView ()

#pragma mark - Private Properties
//! A writable version of the public property.
@property DTSGame *game;

//! The bounds in which the game grid are actually drawn.
@property CGRect insetBounds;

//! The amount of space between rows in the grid.
@property CGFloat rowHeight;

//! The amount of space between columns in the grid.
@property CGFloat columnWidth;

//! The layers representing drawn shapes in the view.
@property NSMutableArray<CAShapeLayer *> *shapes;

/*!
 A phantom edge to draw while the user is choosing an edge and has not yet
 released their finger.
 */
@property (nullable) CAShapeLayer *phantomEdge;

@end

@implementation DTSGameView

#pragma mark - Initialization
+ (instancetype)gameViewWithFrame:(CGRect)frame game:(DTSGame *)game
{
    return [[self alloc] initWithFrame:frame game:game];
}

- (instancetype)initWithFrame:(CGRect)frame game:(DTSGame *)game
{
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }

    _game = game;
    return self;
}

#pragma mark - Resizing
- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];

    // Remove all shapes from the view.
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

    self.insetBounds = CGRectInset(self.bounds, 4 * DTSGameViewDotRadius, 4 * DTSGameViewDotRadius);
    self.rowHeight = self.insetBounds.size.height / self.game.dimensions.height;
    self.columnWidth = self.insetBounds.size.width / self.game.dimensions.width;

    // Add dots to the view.
    CGPathRef dotPath = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, 2 * DTSGameViewDotRadius, 2 * DTSGameViewDotRadius), NULL);
    for (NSUInteger i = 0; i <= self.game.dimensions.height; i += 1) {
        for (NSUInteger j = 0; j <= self.game.dimensions.width; j += 1) {
            CAShapeLayer *dot = [CAShapeLayer layer];
            dot.path = dotPath;
            dot.fillColor = [UIColor dts_textColor].CGColor;
            dot.position = CGPointMake(self.insetBounds.origin.x / 2 + j * _columnWidth, self.insetBounds.origin.y / 2 + i * _rowHeight);

            [self.layer addSublayer:dot];
        }
    }

    CGPathRelease(dotPath);

    // Add horizontal edges.
    for (NSUInteger i = 0; i < self.game.horizontalEdges.count; i += 1) {
        for (NSUInteger j = 0; j < self.game.horizontalEdges[i].count; j += 1) {
            NSInteger player = [self.game.horizontalEdges[i][j] integerValue];
            if (player == 1 || player == 2) {
                DTSEdge edge = {.location = {.x = j, .y = i}, .horizontal = YES};
                CAShapeLayer *edgeLayer = [self createEdgeLayerForEdge:edge];
                edgeLayer.fillColor = [self colorForPlayer:player].CGColor;
                [self.layer addSublayer:edgeLayer];
            }
        }
    }

    // Add vertical edges.
    for (NSUInteger i = 0; i < self.game.verticalEdges.count; i += 1) {
        for (NSUInteger j = 0; j < self.game.verticalEdges[i].count; j += 1) {
            NSInteger player = [self.game.verticalEdges[i][j] integerValue];
            if (player == 1 || player == 2) {
                DTSEdge edge = {.location = {.x = j, .y = i}, .horizontal = NO};
                CAShapeLayer *edgeLayer = [self createEdgeLayerForEdge:edge];
                edgeLayer.fillColor = [self colorForPlayer:player].CGColor;
                [self.layer addSublayer:edgeLayer];
            }
        }
    }

    // Add boxes.
    for (NSUInteger i = 0; i < self.game.boxes.count; i += 1) {
        for (NSUInteger j = 0; j < self.game.boxes[i].count; j += 1) {
            NSInteger player = [self.game.boxes[i][j] integerValue];
            if (player == 1 || player == 2) {
                CAShapeLayer *box = [self createBoxLayerForBoxAtLocation:(DTSLocation){.x = j, .y = i}];
                box.fillColor = [self colorForPlayer:player].CGColor;
                [self.layer addSublayer:box];
            }
        }
    }
}

#pragma mark - Edge Translation
- (DTSLocation)locationOfBoxContainingPoint:(CGPoint)point
{
    point.x = (CGFloat)trunc((point.x - self.insetBounds.origin.x) / self.columnWidth);
    point.y = (CGFloat)trunc((point.y - self.insetBounds.origin.y) / self.rowHeight);

    if (point.x < 0) {
        point.x = 0;
    } else if (point.x >= self.game.dimensions.width) {
        point.x = self.game.dimensions.width - 1;
    }

    if (point.y < 0) {
        point.y = 0;
    } else if (point.y >= self.game.dimensions.height) {
        point.y = self.game.dimensions.height - 1;
    }

    return (DTSLocation){(NSUInteger)point.x, (NSUInteger)point.y};
//    return (DTSLocation){(NSUInteger)trunc(point.x / self.columnWidth), (NSUInteger)trunc(point.y / self.rowHeight)};
}

- (DTSEdge)nearestEdgeToPoint:(CGPoint)point
{
    DTSLocation box = [self locationOfBoxContainingPoint:point];
    CGRect boxFrame = CGRectMake(self.insetBounds.origin.x / 2 + DTSGameViewDotRadius + box.x * self.columnWidth,
                                 self.insetBounds.origin.y / 2 + DTSGameViewDotRadius + box.y * self.rowHeight,
                                 self.columnWidth, self.rowHeight);

    // Are we closer to the top horizontal edge, or the bottom?
    CGFloat distanceToClosestHorizontalEdge = point.y - boxFrame.origin.y;
    BOOL closerToTop = YES;
    if (point.y - boxFrame.origin.y > boxFrame.size.height / 2) {
        closerToTop = NO;
        distanceToClosestHorizontalEdge = boxFrame.size.height - distanceToClosestHorizontalEdge;
    }

    // Are we closer to the left vertical edge, or the right?
    CGFloat distanceToClosestToVerticalEdge = point.x - boxFrame.origin.x;
    BOOL closerToLeft = YES;
    if (point.x - boxFrame.origin.x > boxFrame.size.width / 2) {
        closerToLeft = NO;
        distanceToClosestToVerticalEdge = boxFrame.size.width - distanceToClosestToVerticalEdge;
    }

    // Are we closer to a horizontal edge, or a vertical edge?
    BOOL closerToHorizontal = distanceToClosestHorizontalEdge < distanceToClosestToVerticalEdge;

    if (closerToHorizontal && !closerToTop) {
        box.y += 1;
    } else if (!closerToHorizontal && !closerToLeft) {
        box.x += 1;
    }

    return (DTSEdge){.location = box, .horizontal = closerToHorizontal};
}

#pragma mark - Color Lookup
- (UIColor *)colorForPlayer:(NSInteger)player
{
    return player == 1 ? [UIColor dts_player1Color] : [UIColor dts_player2Color];
}

#pragma mark - Creating Boxes and Edges
- (CAShapeLayer *)createBoxLayerForBoxAtLocation:(DTSLocation)location
{
    CAShapeLayer *box = [CAShapeLayer layer];
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, self.columnWidth - 4 * DTSGameViewDotRadius, self.rowHeight - 4 * DTSGameViewDotRadius), NULL);
    box.path = path;
    CGPathRelease(path);

    box.anchorPoint = CGPointMake(0, 0);
    box.position = CGPointMake(self.insetBounds.origin.x / 2 + 3 * DTSGameViewDotRadius + location.x * self.columnWidth,
                               self.insetBounds.origin.y / 2 + 3 * DTSGameViewDotRadius + location.y * self.rowHeight);
    return box;
}

- (CAShapeLayer *)createEdgeLayerForEdge:(DTSEdge)edge
{
    CAShapeLayer *layer = [CAShapeLayer layer];
    if (edge.horizontal) {
        CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, self.columnWidth - 2 * DTSGameViewDotRadius, DTSGameViewDotRadius), NULL);
        layer.path = path;
        CGPathRelease(path);

        layer.position = CGPointMake(self.insetBounds.origin.x / 2 + edge.location.x * self.columnWidth + 2 * DTSGameViewDotRadius,
                                     self.insetBounds.origin.y / 2 + edge.location.y * self.rowHeight + DTSGameViewDotRadius / 2);
    } else {
        CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, DTSGameViewDotRadius, self.rowHeight - 2 * DTSGameViewDotRadius), NULL);
        layer.path = path;
        CGPathRelease(path);

        layer.position = CGPointMake(self.insetBounds.origin.x / 2 + edge.location.x * self.columnWidth + DTSGameViewDotRadius / 2,
                                     self.insetBounds.origin.y / 2 + edge.location.y * self.rowHeight + 2 * DTSGameViewDotRadius);
    }

    return layer;
}

- (void)showPhantomEdge:(DTSEdge)edge forPlayer:(NSInteger)player
{
    [self.phantomEdge removeFromSuperlayer];

    self.phantomEdge = [self createEdgeLayerForEdge:edge];
    self.phantomEdge.fillColor = [self colorForPlayer:player].CGColor;
    [self.layer addSublayer:self.phantomEdge];
}

#pragma mark - Touch Handling
- (BOOL)isMultipleTouchEnabled
{
    // We only want to receive one touch at a time.
    return NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [[touches anyObject] locationInView:self];

    DTSEdge edge = [self nearestEdgeToPoint:touchLocation];
    if ([self.game canPlayEdge:edge]) {
        [self showPhantomEdge:edge forPlayer:self.game.currentPlayer];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.phantomEdge removeFromSuperlayer];
    self.phantomEdge = nil;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [[touches anyObject] locationInView:self];

    [self.phantomEdge removeFromSuperlayer];
    self.phantomEdge = nil;

    DTSEdge edge = [self nearestEdgeToPoint:touchLocation];
    if ([self.game canPlayEdge:edge]) {
        [self playEdge:edge withDelay:0];
    }
}

#pragma mark - Making Moves on the Board
- (BOOL)playEdge:(DTSEdge)edge withDelay:(NSTimeInterval)delay {
    NSInteger player = [self.game playEdge:edge];
    CAShapeLayer *layer = [self createEdgeLayerForEdge:edge];
    layer.fillColor = [self colorForPlayer:player].CGColor;
    [self.layer addSublayer:layer];

    [NSThread sleepForTimeInterval:delay];

    if (player == self.game.currentPlayer) {
        return YES;
    } else {
        [self.delegate player:player didCompleteTurnInView:self];
        return NO;
    }
}

#pragma mark - DTSGameDelegate
- (void)player:(NSInteger)player didCaptureBoxAtLocation:(DTSLocation)location
{
    CAShapeLayer *box = [self createBoxLayerForBoxAtLocation:location];
    box.fillColor = [self colorForPlayer:player].CGColor;
    [self.layer addSublayer:box];
}

@end
