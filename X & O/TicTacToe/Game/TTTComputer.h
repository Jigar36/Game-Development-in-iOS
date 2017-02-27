//
//  TTTComputer.h
//  TicTacToe
//
//  Created by Jigar Panchal on 4/10/16.
//  Copyright © 2016 Jigar. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "TTTBoard.h"

@interface TTTComputer : NSObject

- (void) moveMarker:(TTTBoardMarker)marker onBoard:(TTTBoard *) board withCallBack:(TTTIntegerBlock)callback;

@end
