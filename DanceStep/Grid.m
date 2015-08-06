//
//  Grid.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/28/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "Grid.h"

@implementation Grid
- (instancetype)initGridWithPosition:(CGPoint)position andPositionIndex:(NSInteger)positionIndex {
    self = [super init];
    if (self) {
        self.position = position;
        self.positionIndex = positionIndex;
        //  grid.position = CGPointMake(i, j);
        //Default values
        self.isOccupied = NO;
        self.content = nil;
        self.viewTag = -1;
    }
    return self;
}

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
//Grids Position property doesn't change once it's initialized only other properties can change.
- (void)resetGridProperties {
    self.isOccupied = NO;
    self.content = nil;
    self.viewTag = -1;
    self.dancerName = nil;

}

//Forlogging purpose
- (void) logContent {
    NSLog(@"\n----------------\n----------------\n  Logging Grid:\n----------------\n----------------");
    NSLog(@"IsOccupied: %hhd",self.isOccupied);
    NSLog(@"Position: %@",NSStringFromCGPoint(self.position));
    NSLog(@"Content: %@",self.content);
    NSLog(@"View Tag: %d",self.viewTag);
    NSLog(@"DancerTag : %@",self.dancerName);
}
@end
