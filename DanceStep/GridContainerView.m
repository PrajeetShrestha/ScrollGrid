//
//  GridContainerView.m
//  DanceStep
//
//  Created by Prajeet Shrestha on 8/4/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import "GridContainerView.h"
@interface GridContainerView () {
    CGFloat gridSize;
}
@end
@implementation GridContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.grids = [NSMutableArray new];
        gridSize = self.frame.size.width/11;
        [self initializeGrids];
    }
    return self;
}

//Create Grid Points in container view
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    gridSize = self.bounds.size.width/11;
    for (float i = gridSize; i < self.bounds.size.width; i += gridSize) {
        for (float j = gridSize; j < self.bounds.size.height; j += gridSize) {
            CGRect dotFrameHorizontal = CGRectMake(i, j, 2, 2);
            CGContextSetFillColorWithColor(ctx, [UIColor groupTableViewBackgroundColor].CGColor);
            CGContextFillEllipseInRect(ctx, CGRectInset(dotFrameHorizontal, 0, 0));
        }
    }
}

//Create imaginary gridpoints
- (void)initializeGrids {

    for (float i = gridSize; i < self.bounds.size.width; i += gridSize) {
        for (float j = gridSize; j < self.bounds.size.height; j += gridSize) {
            CGPoint point = CGPointMake(i, j);
            if (![self isPointAlreadyStoredInGrid:point]) {
                //Default initialization of Grid
                Grid *grid = [Grid new];
                grid.position = CGPointMake(i, j);
                grid.isOccupied = NO;
                grid.content = nil;
                grid.viewTag = -1;
                [self.grids addObject:grid];
            }
        }
    }
    [self logGridPoints];
}

-(BOOL)isPointAlreadyStoredInGrid:(CGPoint)point {
    for (Grid *grd in self.grids){
        if(grd.position.x == point.x && grd.position.y == point.y) {
            if (grd.isOccupied ) {
                return NO;
            } else {
                return YES;
            }
        }
    }
    return NO;
}

- (void)logGridPoints {
    for (Grid *grid in self.grids) {
        NSLog(@"%@ Grid Position",NSStringFromCGPoint(grid.position));
    }
}

#pragma mark - Getters
- (Grid *)getGridAtIndex:(NSUInteger)index {
    return self.grids[index];
}

#pragma mark - Setters
- (void)setGridAtIndex:(Grid *)grid atIndex:(NSUInteger)index{
    [self.grids replaceObjectAtIndex:index withObject:grid];
}




@end
