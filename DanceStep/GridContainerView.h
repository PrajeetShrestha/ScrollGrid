//
//  GridContainerView.h
//  DanceStep
//
//  Created by Prajeet Shrestha on 8/4/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Grid.h"
#import "DancerView.h"  

@interface GridContainerView : UIView
@property NSMutableArray *grids;
@property NSInteger containerIndex;

- (Grid *)getGridAtIndex:(NSInteger)index;

- (void)setGridAtIndex:(Grid *)grid atIndex:(NSUInteger)index;

- (void)addDancer;
- (void)alignHorizontally;
- (void)alignVertically;
- (void)deselectAll;
- (void)selectAll;
- (void)equiDistant;
- (void)undoMove;
- (void)redoMove;

- (void)addDancerInPositions:(NSArray *)positions previousPosition:(NSArray *)previousPositions;

- (void)replicateDancerAtPreviousPosition;


@end
