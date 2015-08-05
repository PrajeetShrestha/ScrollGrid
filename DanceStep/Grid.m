//
//  Grid.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/28/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "Grid.h"

@implementation Grid

- (BOOL)isEquivalentTo:(Grid *)grid {
    BOOL isContentEqual = NO;
    BOOL isOccupiedEqual = NO;
    BOOL isPositionEqual = NO;
    BOOL isViewTagEqual = NO;

    if ([self.content isEqual:grid.content]) {
        isContentEqual = YES;
    }

    if (self.isOccupied == grid.isOccupied) {
        isOccupiedEqual = YES;
    }

    if (self.position.x == grid.position.x && self.position.y == grid.position.y) {
        isPositionEqual = YES;
    }

    if (self.viewTag == grid.viewTag) {
        isViewTagEqual = YES;
    }

    return isContentEqual && isOccupiedEqual && isPositionEqual && isViewTagEqual;
}
//Forlogging purpose
- (void) logContent {
    NSLog(@"\n______________\n______________\nLogging Grid:\n______________\n______________");
    NSLog(@"IsOccupied: %hhd",self.isOccupied);
    NSLog(@"Position: %@",NSStringFromCGPoint(self.position));
    NSLog(@"Content: %@",self.content);
    NSLog(@"View Tag: %d",self.viewTag);
    NSLog(@"DancerTag : %@",self.dancerTag);
}
@end
