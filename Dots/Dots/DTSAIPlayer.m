#import "DTSAIPlayer.h"
#import "DTSGame.h"

@implementation DTSAIPlayer


#pragma mark - Making Moves on a Board
+ (DTSEdge)recommendedMoveForDifficultyLevel:(NSInteger)level inGame:(DTSGame *)game
{
    if (level == 0) {
        return [self makeRandomMoveInGame:game];
    } else if (level == 1) {
        return [self makeGreedyMoveInGame:game];
    } else if (level == 2) {
        return [self makeSmartGreedyMoveInGame:game];
    } else {
        return [self makeBestMoveInGame:game];
    }
}

/*!
 Finds all possible moves, selects a random one to play.
 
 \param game The game to select a random move to play in.
 \returns Edge that was randomly selected to be played.
 */
+ (DTSEdge)makeRandomMoveInGame:(DTSGame *)game
{
    NSMutableArray *moves = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < game.horizontalEdges.count; ++i) {
        for (NSUInteger j = 0; j < game.horizontalEdges[0].count; ++j) {
            DTSEdge edge = {.location = {.x = j, .y = i}, .horizontal = YES};
            if ([game canPlayEdge:edge]) {
                NSValue *wrapper = [NSValue valueWithBytes:&edge objCType:@encode(DTSEdge)];
                [moves addObject:wrapper];
            }
        }
    }
    
    for (NSUInteger i = 0; i < game.verticalEdges.count; ++i) {
        for (NSUInteger j = 0; j < game.verticalEdges[0].count; ++j) {
            DTSEdge edge = {.location = {.x = j, .y = i}, .horizontal = NO};
            if ([game canPlayEdge:edge]) {
                NSValue *wrapper = [NSValue valueWithBytes:&edge objCType:@encode(DTSEdge)];
                [moves addObject:wrapper];
            }
        }
    }
    
    NSUInteger randomIndex = arc4random() % [moves count];
    NSValue *value = moves[randomIndex];
    DTSEdge edge;
    [value getValue:&edge];
    return edge;
}

/*!
 Plays with a greedy strategy, capturing all possible boxes
 
 \param game The game to select and play a move in.
 \returns Edge selected to be played.
 */
+ (DTSEdge)makeGreedyMoveInGame:(DTSGame *)game
{
    NSMutableArray *moves = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < game.horizontalEdges.count; ++i) {
        for (NSUInteger j = 0; j < game.horizontalEdges[0].count; ++j) {
            DTSEdge edge = {.location = {.x = j, .y = i}, .horizontal = YES};
            if ([game canPlayEdge:edge]) {
                if ([game edgeWouldCapture:edge] ) {
                    return edge;
                }
                else {
                    NSValue *wrapper = [NSValue valueWithBytes:&edge objCType:@encode(DTSEdge)];
                    [moves addObject:wrapper];
                }
            }
        }
    }
    for (NSUInteger i = 0; i < game.verticalEdges.count; ++i) {
        for (NSUInteger j = 0; j < game.verticalEdges[0].count; ++j) {
            DTSEdge edge = {.location = {.x = j, .y = i}, .horizontal = NO};
            if ([game canPlayEdge:edge]) {
                if ([game edgeWouldCapture:edge] ) {
                    return edge;
                }
                else {
                    NSValue *wrapper = [NSValue valueWithBytes:&edge objCType:@encode(DTSEdge)];
                    [moves addObject:wrapper];
                }
            }
        }
    }
    
    // No capturing could be done, return move that gives fewest points
    NSUInteger randomIndex = arc4random_uniform((u_int32_t)[moves count]);
    NSValue *value = moves[randomIndex];
    DTSEdge edge;
    [value getValue:&edge];
    return edge;
}

struct WeightedEdge {
    DTSEdge edge;
    NSUInteger weight;
};

+ (DTSEdge)makeSmartGreedyMoveInGame:(DTSGame *)game
{
    NSUInteger bestWeight = 4;
    NSMutableArray *moves = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < game.horizontalEdges.count; ++i) {
        for (NSUInteger j = 0; j < game.horizontalEdges[0].count; ++j) {
            DTSEdge edge = {.location = {.x = j, .y = i}, .horizontal = YES};
            if ([game canPlayEdge:edge]) {
                if ([game edgeWouldCapture:edge] ) {
                    return edge;
                }
                else {
                    NSUInteger weight = [game maxNeighboringEdges:edge];
                    if (weight < bestWeight) {
                        [moves removeAllObjects];
                        bestWeight = weight;
                    }
                    if (weight <= bestWeight) {
                        NSValue *wrapper = [NSValue valueWithBytes:&edge objCType:@encode(DTSEdge)];
                        [moves addObject:wrapper];
                    }
                }
            }
        }
    }
    for (NSUInteger i = 0; i < game.verticalEdges.count; ++i) {
        for (NSUInteger j = 0; j < game.verticalEdges[0].count; ++j) {
            DTSEdge edge = {.location = {.x = j, .y = i}, .horizontal = NO};
            if ([game canPlayEdge:edge]) {
                if ([game edgeWouldCapture:edge] ) {
                    return edge;
                }
                else {
                    NSUInteger weight = [game maxNeighboringEdges:edge];
                    if (weight < bestWeight) {
                        [moves removeAllObjects];
                        bestWeight = weight;
                    }
                    if (weight <= bestWeight) {
                        NSValue *wrapper = [NSValue valueWithBytes:&edge objCType:@encode(DTSEdge)];
                        [moves addObject:wrapper];
                    }
                }
            }
        }
    }
    
    // No capturing could be done, return move that gives fewest points
    NSUInteger randomIndex = arc4random_uniform((u_int32_t)[moves count]);
    NSValue *value = moves[randomIndex];
    DTSEdge edge;
    [value getValue:&edge];
    return edge;
}

+ (void)takeSafeBoxes:(DTSGame *)game
{
    for (NSUInteger i = 0; i < game.boxes.count; ++i) {
        for (NSUInteger j = 0; j < game.boxes[0].count; ++j) {
            DTSLocation loc = {.x = i, .y = j};
            if ([game edgesAroundBox:loc] == 3) {
                DTSEdge e = {.location = loc, .horizontal = NO};
                if (j == 0 || [game canPlayEdge:e]) {
                    
                }
            }
        }
    }
}

+ (NSUInteger)exploreChain:(DTSGame *)game groups:(NSInteger *)chainGroups lengths:(NSUInteger *)chainLengths group:(NSInteger)group box:(DTSLocation)location
{
    if (chainGroups[game.boxes.count * location.y + location.x] >= 0)
        return 0;
    chainGroups[game.boxes.count * location.y + location.x] = group;
    NSUInteger chainLength = 1;
    if ([game boxMissingTopEdge:location] && location.y > 0) {
        DTSLocation locationUp = {.x = location.x, .y = location.y - 1};
        chainLength += [self exploreChain:game groups:chainGroups lengths:chainLengths group:group box:locationUp];
    }
    if ([game boxMissingRightEdge:location] && location.x < game.boxes[0].count - 1) {
        DTSLocation locationRight = {.x = location.x + 1, .y = location.y};
        chainLength += [self exploreChain:game groups:chainGroups lengths:chainLengths group:group box:locationRight];
    }
    if ([game boxMissingBottomEdge:location] && location.y < game.boxes.count - 1) {
        DTSLocation locationDown = {.x = location.x, .y = location.y + 1};
        chainLength += [self exploreChain:game groups:chainGroups lengths:chainLengths group:group box:locationDown];
    }
    if ([game boxMissingLeftEdge:location] && location.x > 0) {
        DTSLocation locationLeft = {.x = location.x - 1, .y = location.y};
        chainLength += [self exploreChain:game groups:chainGroups lengths:chainLengths group:group box:locationLeft];
    }
    return chainLength;
}

+ (NSUInteger)findChains:(DTSGame *)game groups:(NSInteger *)chainGroups lengths:(NSUInteger *)chainLengths
{
    NSInteger chainCount = 0;
    
    for (NSUInteger i = 0; i < game.boxes.count; ++i) {
        for (NSUInteger j = 0; j < game.boxes[0].count; ++j) {
            DTSLocation location = {.x = j, .y = i};
            if (![game boxIsSurrounded:location] && chainGroups[game.boxes.count * i + j] == -1) {
                chainLengths[chainCount] = [self exploreChain:game groups:chainGroups lengths:chainLengths group:chainCount box:location];
                chainCount += 1;
            }
        }
    }
    return (NSUInteger)chainCount;
}

+ (DTSEdge)makeBestMoveInGame:(DTSGame *)game
{
    NSInteger chainGroups[game.boxes.count * game.boxes[0].count];
    memset(chainGroups, 0, sizeof(chainGroups));
    
    NSUInteger chainLengths[game.boxes.count * game.boxes[0].count];
    NSUInteger numChainsOfLength[game.boxes.count * game.boxes[0].count];
    
    for (NSUInteger i = 0; i < game.boxes.count; ++i) {
        for (NSUInteger j = 0; j < game.boxes[0].count; ++j) {
            chainGroups[game.boxes.count * i + j] = -1;
            chainLengths[game.boxes.count * i + j] = 0;
            numChainsOfLength[game.boxes.count * i + j] = 0;
        }
    }
    
    NSUInteger chainCount = [self findChains:game groups:chainGroups lengths:chainLengths];
    
    NSUInteger minChainLength = game.boxes.count*game.boxes[0].count;
    for (NSUInteger i = 0; i < chainCount; ++i) {
        numChainsOfLength[chainLengths[i]] += 1;
        if (chainLengths[i] < minChainLength) {
            minChainLength = chainLengths[i];
        }
    }
    
    
    NSUInteger bestWeight = 4;
    NSMutableArray *moves = [NSMutableArray array];
    NSMutableArray *captureMoves = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < game.horizontalEdges.count; ++i) {
        for (NSUInteger j = 0; j < game.horizontalEdges[0].count; ++j) {
            DTSEdge edge = {.location = {.x = j, .y = i}, .horizontal = YES};
            if ([game canPlayEdge:edge]) {
                if ([game edgeWouldCapture:edge] ) {
                    NSValue *wrapper = [NSValue valueWithBytes:&edge objCType:@encode(DTSEdge)];
                    [captureMoves addObject:wrapper];
                }
                else {
                    NSUInteger weight = [game maxNeighboringEdges:edge];
                    if (weight < bestWeight) {
                        [moves removeAllObjects];
                        bestWeight = weight;
                    }
                    if (weight <= bestWeight) {
                        NSValue *wrapper = [NSValue valueWithBytes:&edge objCType:@encode(DTSEdge)];
                        [moves addObject:wrapper];
                    }
                }
            }
        }
    }
    for (NSUInteger i = 0; i < game.verticalEdges.count; ++i) {
        for (NSUInteger j = 0; j < game.verticalEdges[0].count; ++j) {
            DTSEdge edge = {.location = {.x = j, .y = i}, .horizontal = NO};
            if ([game canPlayEdge:edge]) {
                if ([game edgeWouldCapture:edge] ) {
                    NSValue *wrapper = [NSValue valueWithBytes:&edge objCType:@encode(DTSEdge)];
                    [captureMoves addObject:wrapper];
                }
                else {
                    NSUInteger weight = [game maxNeighboringEdges:edge];
                    if (weight < bestWeight) {
                        [moves removeAllObjects];
                        bestWeight = weight;
                    }
                    if (weight <= bestWeight) {
                        NSValue *wrapper = [NSValue valueWithBytes:&edge objCType:@encode(DTSEdge)];
                        [moves addObject:wrapper];
                    }
                }
            }
        }
    }
    
    for (NSUInteger i = 0; i < game.boxes.count; ++i) {
        for (NSUInteger j = 0; j < game.boxes[0].count; ++j) {
            DTSLocation loc = {.x = j, .y = i};
            if ([game edgesAroundBox:loc] == 3) {
                if ((chainLengths[chainGroups[game.boxes.count * i + j]] != 2) || (chainLengths[chainGroups[game.boxes.count * i + j]] == 2 && numChainsOfLength[2] > 1) || (moves.count > 0 && bestWeight < 2)) {
                    DTSEdge edge = {.location = loc, .horizontal = NO};
                    
                    // Try to optimally play the 4-chains
                    if ((chainLengths[chainGroups[game.boxes.count * i + j]] == 4) && (chainCount > 1) && (numChainsOfLength[4] == 1) && (minChainLength == 4) && (moves.count > 0 && bestWeight == 2)) {
                        DTSLocation neighborLoc = loc;
                        edge.location = neighborLoc;
                        if ([game boxMissingTopEdge:loc]) {
                            edge.location.y -= 1;
                            if ([game boxMissingTopEdge:edge.location]) {
                                edge.horizontal = YES;
                                return edge;
                            }
                            if ([game boxMissingRightEdge:edge.location]) {
                                edge.location.x += 1;
                                return edge;
                            }
                            if ([game boxMissingLeftEdge:edge.location]) {
                                return edge;
                            }
                        }
                        else if ([game boxMissingBottomEdge:loc]) {
                            edge.location.y += 1;
                            if ([game boxMissingBottomEdge:edge.location]) {
                                edge.location.y += 1;
                                edge.horizontal = YES;
                                return edge;
                            }
                            if ([game boxMissingRightEdge:edge.location]) {
                                edge.location.x += 1;
                                return edge;
                            }
                            if ([game boxMissingLeftEdge:edge.location]) {
                                return edge;
                            }
                        }
                        else if ([game boxMissingLeftEdge:loc]) {
                            edge.location.x -= 1;
                            if ([game boxMissingBottomEdge:edge.location]) {
                                edge.location.y += 1;
                                edge.horizontal = YES;
                                return edge;
                            }
                            if ([game boxMissingTopEdge:edge.location]) {
                                edge.horizontal = YES;
                                return edge;
                            }
                            if ([game boxMissingLeftEdge:edge.location]) {
                                return edge;
                            }
                        }
                        else if ([game boxMissingRightEdge:loc]) {
                            edge.location.x += 1;
                            if ([game boxMissingBottomEdge:edge.location]) {
                                edge.location.y += 1;
                                edge.horizontal = YES;
                                return edge;
                            }
                            if ([game boxMissingTopEdge:edge.location]) {
                                edge.horizontal = YES;
                                return edge;
                            }
                            if ([game boxMissingRightEdge:edge.location]) {
                                edge.location.x += 1;
                                return edge;
                            }
                        }
                    }
                    
                    if ([game boxMissingTopEdge:loc]) {
                        edge.horizontal = YES;
                        return edge;
                    }
                    else if ([game boxMissingBottomEdge:loc]) {
                        edge.horizontal = YES;
                        edge.location.y += 1;
                        return edge;
                    }
                    else if ([game boxMissingRightEdge:loc]) {
                        edge.location.x += 1;
                        return edge;
                    }
                    else {
                        return edge;
                    }
                }
            }
        }
    }
    
    // Can take boxes and still play safe moves
    if (captureMoves.count > 0 && moves.count > 0 && bestWeight < 2) {
        NSUInteger randomIndex = arc4random_uniform((u_int32_t)[captureMoves count]);
        NSValue *value = captureMoves[randomIndex];
        DTSEdge capEdge;
        [value getValue:&capEdge];
        return capEdge;
    }
    else if (moves.count > 0 && bestWeight < 2) {
        NSUInteger randomIndex = arc4random_uniform((u_int32_t)[moves count]);
        NSValue *value = moves[randomIndex];
        DTSEdge edge;
        [value getValue:&edge];
        return edge;
    }
    
    if (minChainLength == 2) {
        if (chainCount == 1 && captureMoves.count > 0) {
            NSValue *value = captureMoves[0];
            DTSEdge edge;
            [value getValue:&edge];
            return edge;
        }
        
        // More than one chain remaining, win the 2-chain
        // Forced to capture the 2-chain
        DTSEdge cachedTwoEdge = {.location = {.x = 0, .y = 0}, .horizontal = YES};
        BOOL useCachedEdge = NO;
        for (NSUInteger i = 0; i < game.boxes.count; ++i) {
            for (NSUInteger j = 0; j < game.boxes[0].count; ++j) {
                if (chainLengths[chainGroups[game.boxes.count * i + j]] == 2) {
                    DTSLocation loc = {.x = j, .y = i};
                    
                    // Vertical case
                    if (i < game.boxes.count - 1 && [game boxMissingBottomEdge:loc]) {
                        DTSLocation locDown = {.x = j, .y = i + 1};
                        BOOL threeBox = [game edgesAroundBox:loc] == 3 || [game edgesAroundBox:locDown] == 3;
                        NSUInteger twoBox = ([game edgesAroundBox:loc] == 2) ? 1 : ([game edgesAroundBox:locDown] == 2) ? 2 : 0;
                        
                        // Play forcing move on the two box
                        if (threeBox && twoBox) {
                            DTSEdge edge = {.location = loc, .horizontal = NO};
                            if (twoBox == 1) {
                                if ([game boxMissingRightEdge:loc]) {
                                    edge.location.x += 1;
                                }
                                else if ([game boxMissingTopEdge:loc]) {
                                    edge.horizontal = YES;
                                }
                            }
                            else {
                                edge.location.y += 1;
                                if ([game boxMissingRightEdge:locDown]) {
                                    edge.location.x += 1;
                                }
                                else if ([game boxMissingBottomEdge:locDown]) {
                                    edge.location.y += 1;
                                    edge.horizontal = YES;
                                }
                            }
                            return edge;
                        }
                        else if (!useCachedEdge) {
                            cachedTwoEdge.location = locDown;
                            useCachedEdge = YES;
                        }
                    }
                    // Horizontal (Right)
                    else if (j < game.boxes[0].count - 1 && [game boxMissingRightEdge:loc]) {
                        DTSLocation locRight = {.x = j + 1, .y = i};
                        BOOL threeBox = [game edgesAroundBox:loc] == 3 || [game edgesAroundBox:locRight] == 3;
                        NSUInteger twoBox = ([game edgesAroundBox:loc] == 2) ? 1 : ([game edgesAroundBox:locRight] == 2) ? 2 : 0;
                        
                        // Play forcing move on the two box
                        if (threeBox && twoBox) {
                            DTSEdge edge = {.location = loc, .horizontal = YES};
                            if (twoBox == 1) {
                                if ([game boxMissingBottomEdge:loc]) {
                                    edge.location.y += 1;
                                }
                                else if ([game boxMissingLeftEdge:loc]) {
                                    edge.horizontal = NO;
                                }
                            }
                            else {
                                edge.location.x += 1;
                                if ([game boxMissingBottomEdge:locRight]) {
                                    edge.location.y += 1;
                                }
                                else if ([game boxMissingRightEdge:locRight]) {
                                    edge.location.x += 1;
                                    edge.horizontal = NO;
                                }
                            }
                            return edge;
                        }
                        else if (!useCachedEdge) {
                            cachedTwoEdge.location = locRight;
                            cachedTwoEdge.horizontal = NO;
                            useCachedEdge = YES;
                        }

                    }
                }
            }
        }
        
        for (NSUInteger i = 0; i < moves.count; ++i) {
            NSValue *value = moves[i];
            DTSEdge edge;
            [value getValue:&edge];
            
            if (edge.horizontal && edge.location.y > 0 && edge.location.y < game.verticalEdges.count - 1) {
                NSInteger edgeGroupTop = chainGroups[game.boxes.count * (edge.location.y - 1) + edge.location.x];
                NSInteger edgeGroupBottom = chainGroups[game.boxes.count * edge.location.y + edge.location.x];
                if (edgeGroupTop == edgeGroupBottom && chainLengths[edgeGroupTop] == 2) {
                    return edge;
                }
            }
            else {
                if (!edge.horizontal && edge.location.x > 0 && edge.location.x < game.horizontalEdges[0].count - 1) {
                    NSInteger edgeGroupLeft = chainGroups[game.boxes.count * edge.location.y + edge.location.x - 1];
                    NSInteger edgeGroupRight = chainGroups[game.boxes.count * edge.location.y + edge.location.x + 1];
                    if (edgeGroupLeft == edgeGroupRight && chainLengths[edgeGroupLeft] == 2) {
                        return edge;
                    }
                }
            }
        }
        
        if (useCachedEdge) {
            return cachedTwoEdge;
        }
    }
    else if (captureMoves.count > 0) {
        NSValue *value = captureMoves[0];
        DTSEdge edge;
        [value getValue:&edge];
        return edge;
    }

    // Only capturing moves left on the board
    if (moves.count == 0) {
        NSUInteger randomIndex = arc4random_uniform((u_int32_t)[captureMoves count]);
        NSValue *value = captureMoves[randomIndex];
        DTSEdge capEdge;
        [value getValue:&capEdge];
        return capEdge;
    }
    
    // Play edge in the shortest chain
    for (NSUInteger i = 0; i < moves.count; ++i) {
        NSUInteger randomIndex = arc4random_uniform((u_int32_t)[moves count]);
        NSValue *value = moves[randomIndex];
        DTSEdge edge;
        [value getValue:&edge];
        DTSLocation loc = edge.location;
        if (edge.horizontal && loc.y == game.boxes.count) {
            loc.y -= 1;
        } else if (!edge.horizontal && loc.x == game.boxes[0].count) {
            loc.x -= 1;
        }
        if (chainLengths[chainGroups[game.boxes.count * loc.y + loc.x]] == minChainLength) {
            return edge;
        }
    }
    NSUInteger randomIndex = arc4random_uniform((u_int32_t)[moves count]);
    NSValue *value = moves[randomIndex];
    DTSEdge edge;
    [value getValue:&edge];
    return edge;
}

@end
