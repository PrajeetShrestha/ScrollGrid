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
- (void)initializeGrids;
- (void)addDancer;
- (Grid *)getGridAtIndex:(NSInteger)index;
- (void)setGridAtIndex:(Grid *)grid atIndex:(NSUInteger)index;
@end
