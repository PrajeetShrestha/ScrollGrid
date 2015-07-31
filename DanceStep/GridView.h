//
//  GridView.h
//  DanceStep
//
//  Created by Prajeet Shrestha on 7/29/15.
//  Copyright (c) 2015 EK Solutions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GridView;
@protocol GridView <NSObject>
- (void)dancerTouchBegan;
- (void)dancerTouchEnd:(GridView *)view;
- (void)dancerMoved;
@end
@interface GridView : UIView
@property (nonatomic) CGPoint previousPosition;
@property (nonatomic) CGPoint latestPosition;
@property (nonatomic) BOOL isColorSet;
@property (nonatomic,weak) id <GridView> delegate;

- (void)viewStateSelected;
- (void)viewStateDeselected;
- (void)expand;
- (void)shrink;
- (void)setColorWhenTouchedForFirstTime;
@end
